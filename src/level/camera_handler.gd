extends Node2D
class_name CameraHandler

# TODO: Update this to instead be logarithmic.
const CAMERA_PAN_SPEED_PER_TIER_MULTIPLIER := 3.0
const CAMERA_START_ZOOM_PRE_STUCK := 0.3
const CAMERA_START_PLAYER_POSITION_OFFSET_PRE_STUCK := Vector2(0.0, -8.0)
const CAMERA_START_POSITION_POST_STUCK := Vector2(0.0, -128.0)
const CAMERA_HORIZONTAL_LOCK_DISPLACMENT_TWEEN_DURATION_SEC := 0.6

# This is how many tiers the player must pass through without falling before
# hitting the max camera scroll speed and framerate speed.
const MAX_SPEED_INDEX := 7
const SPEED_INDEX_DECREMENT_AMOUNT := 2
const SPEED_INCREASE_EASING := "linear"

var speed_index := 0
var level_id: String
var tier_id: String
var player_position: Vector2
var player_height: float
var tier_position: Vector2

var camera_max_distance_below_player_with_default_zoom := INF
var player_max_distance_below_camera_with_default_zoom := INF

var camera_position := -Vector2.INF
var camera_speed := 0.0
var camera_zoom := 1.0
var camera_horizontally_locked := true
var is_camera_post_stuck_state_tween_active := false

var fall_height := -INF

var camera_horizontal_lock_displacement_tween: Tween
var camera_horizontal_lock_tween_displacement := 0.0

func _enter_tree() -> void:
    Global.connect( \
            "display_resized", \
            self, \
            "_handle_display_resize")
    _handle_display_resize()
    
    camera_horizontal_lock_displacement_tween = Tween.new()
    add_child(camera_horizontal_lock_displacement_tween)
    
    var camera := Camera2D.new()
    add_child(camera)
    Global.camera_controller.set_current_camera(camera)

func destroy() -> void:
    speed_index = 0
    camera_position = -Vector2.INF
    _update_camera_position()
    Global.camera_controller.animate_to_zoom(CAMERA_START_ZOOM_PRE_STUCK)

func _process(_delta_sec: float) -> void:
    _update_camera_position()

func sync_to_player_position( \
        delta_modified_sec: float, \
        player_position: Vector2, \
        player_height: float, \
        tier_position: Vector2) -> void:
    self.player_position = player_position
    self.player_height = player_height
    self.tier_position = tier_position
    
    # Update camera pan, according to auto-scroll speed.
    var camera_displacement_for_frame := camera_speed * delta_modified_sec
    camera_position.y -= camera_displacement_for_frame
    
    # Update camera pan, to never be too far below the player.
    if _get_camera_height() < \
            player_height - \
            camera_max_distance_below_player_with_default_zoom * camera_zoom:
        var additional_offset := \
                player_height - \
                camera_max_distance_below_player_with_default_zoom * \
                        camera_zoom - \
                _get_camera_height()
        camera_position.y -= additional_offset
    
    if !is_camera_post_stuck_state_tween_active:
        if camera_horizontally_locked:
            camera_position.x = \
                    tier_position.x + \
                    camera_horizontal_lock_tween_displacement
        else:
            camera_position.x = \
                    player_position.x + \
                    camera_horizontal_lock_tween_displacement
    
    fall_height = \
            _get_camera_height() - \
            player_max_distance_below_camera_with_default_zoom * camera_zoom

func update_for_current_tier( \
        level_id: String, \
        tier_id: String, \
        is_new_life: bool) -> void:
    self.level_id = level_id
    self.tier_id = tier_id
    var is_base_tier := tier_id == "0"
    if is_new_life:
        fall_height = -INF
        camera_speed = 0.0
        Time.physics_framerate_multiplier = _get_min_framerate_multiplier()
    else:
        _increment_speed()
    _update_zoom(!is_base_tier)
    _update_camera_horizontally_locked( \
            LevelConfig.get_tier_config(tier_id).camera_horizontally_locked)

func on_fall_before_new_tier(shakes_harder: bool) -> void:
    camera_speed = 0.0
    var shake_strength := 1.0 if shakes_harder else 0.8
    $CameraShake.shake(shake_strength)

func on_new_tier_after_fall( \
        current_tier_position: Vector2, \
        player_position: Vector2, \
        player_height: float) -> void:
    self.player_position = player_position
    self.player_height = player_height
    _decrement_speed()
    camera_speed = 0.0
    camera_position = Vector2( \
            0.0, \
            CAMERA_START_POSITION_POST_STUCK.y + current_tier_position.y)

func _get_min_framerate_multiplier() -> float:
    match Global.difficulty_mode:
        DifficultyMode.EASY:
            return LevelConfig.FRAMERATE_MULTIPLIER_EASY_MIN
        DifficultyMode.MODERATE:
            return LevelConfig.FRAMERATE_MULTIPLIER_MODERATE_MIN
        DifficultyMode.HARD:
            return LevelConfig.FRAMERATE_MULTIPLIER_HARD_MIN
        _:
            Utils.error()
            return INF

func _get_max_framerate_multiplier() -> float:
    match Global.difficulty_mode:
        DifficultyMode.EASY:
            return LevelConfig.FRAMERATE_MULTIPLIER_EASY_MAX
        DifficultyMode.MODERATE:
            return LevelConfig.FRAMERATE_MULTIPLIER_MODERATE_MAX
        DifficultyMode.HARD:
            return LevelConfig.FRAMERATE_MULTIPLIER_HARD_MAX
        _:
            Utils.error()
            return INF

func _increment_speed() -> void:
    speed_index += 1
    speed_index = min(speed_index, MAX_SPEED_INDEX)
    update_speed()

func _decrement_speed() -> void:
    speed_index -= SPEED_INDEX_DECREMENT_AMOUNT
    speed_index = max(speed_index, 0)
    update_speed()

func update_speed() -> void:
    var speed_index_progress := \
            float(speed_index) / float(MAX_SPEED_INDEX)
    # An ease-out curve.
    speed_index_progress = Utils.ease_by_name( \
            speed_index_progress, \
            SPEED_INCREASE_EASING)
    
    var level_config: Dictionary = LevelConfig.get_level_config(level_id)
    var tier_config: Dictionary = LevelConfig.get_tier_config(tier_id)
    
    var camera_speed_multiplier: float = LevelConfig.get_value( \
            level_id, \
            tier_id, \
            "scroll_speed_multiplier")
    var scroll_speed_min: float = LevelConfig.get_value( \
            level_id, \
            tier_id, \
            "scroll_speed_min")
    var scroll_speed_max: float = LevelConfig.get_value( \
            level_id, \
            tier_id, \
            "scroll_speed_max")
    
    camera_speed = lerp( \
            scroll_speed_min / camera_speed_multiplier, \
            scroll_speed_max / camera_speed_multiplier, \
            speed_index_progress)
    camera_speed *= camera_speed_multiplier
    camera_speed = clamp(camera_speed, scroll_speed_min, scroll_speed_max)
    
    var frame_rate_multiplier_min := _get_min_framerate_multiplier()
    var frame_rate_multiplier_max := _get_max_framerate_multiplier()
    
    Time.physics_framerate_multiplier = lerp( \
            frame_rate_multiplier_min, \
            frame_rate_multiplier_max, \
            speed_index_progress)
    
    Global.print( \
            ("Updated speed: " + \
            "index=%s; " + \
            "scroll_speed=%s; " + \
            "frame_rate_multiplier=%s") % [
                speed_index,
                camera_speed,
                Time.physics_framerate_multiplier,
            ])

func _update_zoom(updates_camera := true) -> void:
    camera_zoom = \
            CameraController.DEFAULT_CAMERA_ZOOM * \
            LevelConfig.get_value(level_id, tier_id, "zoom_multiplier")
    if updates_camera:
        Global.camera_controller.animate_to_zoom(camera_zoom)

func _update_camera_horizontally_locked(locked: bool) -> void:
    if camera_horizontally_locked == locked:
        return
    
    camera_horizontally_locked = locked
    
    var start_value: float = \
            Global.camera_controller.offset.x if \
            camera_horizontally_locked else \
            -player_position.x
    camera_horizontal_lock_displacement_tween.stop(self)
    camera_horizontal_lock_displacement_tween.interpolate_property( \
            self, \
            "camera_horizontal_lock_tween_displacement", \
            start_value, \
            0.0, \
            CAMERA_HORIZONTAL_LOCK_DISPLACMENT_TWEEN_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT)
    camera_horizontal_lock_displacement_tween.start()

func _handle_display_resize() -> void:
    var game_area_size: Vector2 = Global.get_game_area_region().size
    camera_max_distance_below_player_with_default_zoom = game_area_size.y / 4
    player_max_distance_below_camera_with_default_zoom = \
            game_area_size.y / 2 + 4.0

func set_start_state( \
        player_position: Vector2, \
        player_height: float) -> void:
    self.player_position = player_position
    self.player_height = player_height
    camera_position = _get_camera_start_position_pre_stuck()
    Global.camera_controller.zoom = CAMERA_START_ZOOM_PRE_STUCK

func set_post_stuck_state(animates: bool) -> void:
    if animates:
        assert(camera_position == _get_camera_start_position_pre_stuck())
        var tween := Tween.new()
        add_child(tween)
        tween.interpolate_method( \
                self, \
                "_interpolate_camera_to_post_stuck_state", \
                0.0, \
                1.0, \
                Constants.TRANSITION_TO_POST_STUCK_DURATION_SEC, \
                Tween.TRANS_QUAD, \
                Tween.EASE_IN_OUT)
        tween.connect( \
                "tween_completed", \
                self, \
                "_on_camera_post_stuck_state_completed")
        tween.start()
        is_camera_post_stuck_state_tween_active = true
    else:
        _interpolate_camera_to_post_stuck_state(1.0)

func _interpolate_camera_to_post_stuck_state(progress: float) -> void:
    # Update camera pan.
    var camera_position_pre_stuck := _get_camera_start_position_pre_stuck()
    var camera_position_post_stuck := CAMERA_START_POSITION_POST_STUCK
    var start_offset := camera_position_pre_stuck - camera_position_post_stuck
    var end_offset := Vector2.ZERO
    var current_offset: Vector2 = lerp(start_offset, end_offset, progress)
    camera_position = camera_position_post_stuck + current_offset
    
    # Update camera zoom.
    var start_zoom := CAMERA_START_ZOOM_PRE_STUCK
    var end_zoom := camera_zoom
    var current_zoom: float = lerp(start_zoom, end_zoom, progress)
    Global.camera_controller.zoom = current_zoom

func _on_camera_post_stuck_state_completed( \
        _object: Object, \
        _key: NodePath) -> void:
    is_camera_post_stuck_state_tween_active = false

func _get_camera_start_position_pre_stuck() -> Vector2:
    return Vector2(player_position.x, -player_height) + \
            CAMERA_START_PLAYER_POSITION_OFFSET_PRE_STUCK

func _get_camera_height() -> float:
    return -camera_position.y

func _update_camera_position() -> void:
    Global.camera_controller.offset = \
            Utils.floor_vector(camera_position)
    Global.camera_controller.offset = \
            Utils.floor_vector(camera_position) + \
            $CameraShake.position
    Global.camera_controller._current_camera.rotation = $CameraShake.rotation
