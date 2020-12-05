extends Node2D
class_name Level

const MOBILE_CONTROL_UI_RESOURCE_PATH := "res://src/mobile_control_ui.tscn"
const SCORE_BOARDS_RESOURCE_PATH := "res://src/overlays/score_boards.tscn"
const PLAYER_RESOURCE_PATH := "res://src/player/tuber_player.tscn"
const TIER_RATIO_SIGN_RESOURCE_PATH := \
        "res://src/overlays/tier_ratio_sign.tscn"
const PAUSE_BUTTON_RESOURCE_PATH := "res://src/overlays/pause_button.tscn"
const FOG_SCREEN_RESOURCE_PATH := "res://src/level/fog_screen.tscn"

const START_TIER_ID := "0"

const INPUT_SIGN_POSITION := Vector2(0.0, 10.0)

const PLAYER_START_VELOCITY := Vector2(0.0, -300.0)

# TODO: Update this to instead be logarithmic.
const CAMERA_PAN_SPEED_PER_TIER_MULTIPLIER := 3.0
const NUMBER_OF_LEVELS_PER_MUSIC := 1

# How many pixels correspond to a single display-height unit. 
const DISPLAY_HEIGHT_INTERVAL := 32.0

const CAMERA_START_ZOOM_PRE_STUCK := 0.3
const CAMERA_START_PLAYER_POSITION_OFFSET_PRE_STUCK := Vector2(0.0, -8.0)
const CAMERA_START_POSITION_POST_STUCK := Vector2(0.0, -128.0)
const CAMERA_PAN_TO_POST_STUCK_DURATION_SEC := 0.5
const CAMERA_HORIZONTAL_LOCK_DISPLACMENT_TWEEN_DURATION_SEC := \
        CameraController.ZOOM_ANIMATION_DURATION_SEC
const PEEP_HOLE_SIZE_PRE_STUCK := Vector2(96.0, 96.0)
const PEEP_HOLE_SIZE_POST_STUCK := Vector2(256.0, 256.0)
const FOG_SCREEN_OPACITY_PRE_STUCK := 1.0
const FOG_SCREEN_OPACITY_POST_STUCK := 1.0
const FOG_SCREEN_COLOR_PRE_STUCK := Color.white
const FOG_SCREEN_COLOR_POST_STUCK := Color.white
const DEFAULT_WINDINESS := 1.0

# This is how many tiers the player must pass through without falling before
# hitting the max camera scroll speed and framerate speed.
const MAX_SPEED_INDEX := 9
const SPEED_INDEX_DECREMENT_AMOUNT := 1
const SPEED_INCREASE_EASING := "linear"

const SCORE_PER_HEIGHT_PIXELS := 1.0 / DISPLAY_HEIGHT_INTERVAL
const _BASE_SCORE_FOR_TIER := 2048.0 * SCORE_PER_HEIGHT_PIXELS * 0.25
const SCORE_FOR_TIER_FOR_EASY_DIFFICULTY := _BASE_SCORE_FOR_TIER * 0.75
const SCORE_FOR_TIER_FOR_MODERATE_DIFFICULTY := _BASE_SCORE_FOR_TIER * 1.0
const SCORE_FOR_TIER_FOR_HARD_DIFFICULTY := _BASE_SCORE_FOR_TIER * 1.25

var has_input_been_pressed := false

var speed_index := 0

var camera_max_distance_below_player_with_default_zoom := INF
var player_max_distance_below_camera_with_default_zoom := INF

var mobile_control_ui: MobileControlUI
var score_boards: ScoreBoards
var cooldown_indicator: ScoreMultiplierCooldownIndicator
var max_height_indicator: MaxHeightIndicator
var max_height_on_current_height_indicator: MaxHeightIndicator
var pause_button: PauseButton

var level_id := ""

var start_time := -INF

var start_tier_id := START_TIER_ID
var current_tier_id := START_TIER_ID

var current_tier_index := -1

var previous_tier: Tier
var current_tier: Tier
var next_tier: Tier
var previous_tier_gap: TierGap
var next_tier_gap: TierGap
var current_tier_ratio_sign: TierRatioSign
var next_tier_ratio_sign: TierRatioSign

var fog_screen: FogScreen

var player: TuberPlayer
var player_current_height: float = 0.0
var player_max_height: float = 0.0
var player_max_height_on_current_life: float = 0.0
var player_latest_platform_height: float = 0.0
var player_max_platform_height: float = 0.0
var player_max_platform_height_on_current_life: float = 0.0
var tier_count: int = 0
var display_height: int = 0
var falls_count: int = 0
var lives_count: int = LevelConfig.DEFAULT_LIVES_COUNT
var score := 0.0

var current_camera_height := -CAMERA_START_POSITION_POST_STUCK.y
var camera_position := -Vector2.INF
var camera_speed := 0.0
var camera_zoom := 1.0
var camera_horizontally_locked := true
var is_camera_post_stuck_state_tween_active := false

var windiness := DEFAULT_WINDINESS
var peep_hole_size := PEEP_HOLE_SIZE_PRE_STUCK
var fog_screen_opacity := FOG_SCREEN_OPACITY_PRE_STUCK
var fog_screen_color := FOG_SCREEN_COLOR_PRE_STUCK

var current_fall_height := -INF
var is_game_playing := false

var camera_horizontal_lock_displacement_tween: Tween
var camera_horizontal_lock_tween_displacement := 0.0

var peep_hole_size_tween: Tween
var fog_screen_opacity_tween: Tween
var fog_screen_color_tween: Tween
var windiness_tween: Tween

var tiers_count_since_falling := 0

func _enter_tree() -> void:
    Global.level = self
    
    Global.connect( \
            "display_resized", \
            self, \
            "_handle_display_resize")
    _handle_display_resize()
    
    score_boards = Utils.add_scene( \
            Global.canvas_layers.hud_layer, \
            SCORE_BOARDS_RESOURCE_PATH, \
            true, \
            false)
    
    cooldown_indicator = ScoreMultiplierCooldownIndicator.new()
    Global.canvas_layers.hud_layer.add_child(cooldown_indicator)
    cooldown_indicator.visible = Global.is_multiplier_cooldown_indicator_shown
    
    var extra_radius := 2.0
    var extra_distance_from_cone_end_point_to_circle_center := \
            extra_radius * 1.8
    var origin_offset := extra_distance_from_cone_end_point_to_circle_center
    
    max_height_on_current_height_indicator = MaxHeightIndicator.new( \
            Constants.INDICATOR_BLUE_COLOR, \
            extra_radius, \
            extra_distance_from_cone_end_point_to_circle_center, \
            0.0, \
            true)
    add_child(max_height_on_current_height_indicator)
    max_height_on_current_height_indicator.visible = \
            Global.is_height_indicator_shown
    
    max_height_indicator = MaxHeightIndicator.new( \
            Constants.INDICATOR_GREEN_COLOR, \
            0.0, \
            0.0, \
            origin_offset, \
            false)
    add_child(max_height_indicator)
    max_height_indicator.visible = Global.is_height_indicator_shown
    
    camera_horizontal_lock_displacement_tween = Tween.new()
    add_child(camera_horizontal_lock_displacement_tween)
    
    peep_hole_size_tween = Tween.new()
    add_child(peep_hole_size_tween)
    
    fog_screen_opacity_tween = Tween.new()
    add_child(fog_screen_opacity_tween)
    
    fog_screen_color_tween = Tween.new()
    add_child(fog_screen_color_tween)
    
    windiness_tween = Tween.new()
    add_child(windiness_tween)
    
    pause_button = Utils.add_scene( \
            Global.canvas_layers.hud_layer, \
            PAUSE_BUTTON_RESOURCE_PATH, \
            true, \
            true)
    
    var camera := Camera2D.new()
    add_child(camera)
    Global.camera_controller.set_current_camera(camera)
    
    fog_screen = Utils.add_scene( \
            Global.canvas_layers.game_screen_layer, \
            FOG_SCREEN_RESOURCE_PATH, \
            true, \
            true)

func _unhandled_input(event: InputEvent) -> void:
    if !has_input_been_pressed and \
            (event.is_action_pressed("jump") or \
            event.is_action_pressed("move_left") or \
            event.is_action_pressed("move_right") or \
            ((event is InputEventMouseButton or \
            event is InputEventScreenTouch) and \
            event.pressed)):
        has_input_been_pressed = true
        
        # Only instantiate the player once the user has pressed a movement
        # button.
        if is_game_playing and \
                player != null and \
                player.is_stuck:
            _release_player()
        
        if current_tier_id != "0":
            _update_speed()

func _handle_display_resize() -> void:
    var game_area_size: Vector2 = Global.get_game_area_region().size
    camera_max_distance_below_player_with_default_zoom = game_area_size.y / 4
    player_max_distance_below_camera_with_default_zoom = \
            game_area_size.y / 2 - 4.0

func start( \
        level_id: String, \
        tier_id := START_TIER_ID) -> void:
    self.level_id = level_id
    self.start_time = Time.elapsed_play_time_actual_sec
    visible = true
    is_game_playing = true
    lives_count = LevelConfig.LEVELS[level_id].lives_count
    falls_count = 0
    score = 0.0
    _start_new_tier( \
            tier_id, \
            Vector2.ZERO, \
            Audio.START_MUSIC_INDEX)
    Audio.cross_fade_music(Audio.current_music_player_index)
    score_boards.visible = true

func _physics_process(_delta_sec: float) -> void:
    _delta_sec *= Time.physics_framerate_multiplier
    
    if !is_game_playing or \
            player == null or \
            player.is_stuck:
        return
    
    # Keep track of player height.
    player_current_height = \
            -player.position.y - player.get_player_half_height()
    var next_tier_height: float = -next_tier.position.y + Constants.CELL_SIZE.y
    if player_current_height > next_tier_height - 0.1:
        _on_entered_new_tier()
    player_max_height = max(player_max_height, player_current_height)
    player_max_height_on_current_life = \
            max(player_max_height_on_current_life, player_current_height)
    if player.surface_state.just_touched_floor:
        player_latest_platform_height = -player.surface_state.touch_position.y
        var platform_height_delta := \
                player_latest_platform_height - player_max_platform_height if \
                player_latest_platform_height > \
                        player_max_platform_height else \
                0.0
        player_max_platform_height = \
                max(player_max_platform_height, player_current_height)
        player_max_platform_height_on_current_life = max( \
                player_max_platform_height_on_current_life, \
                player_current_height)
        _update_score_for_height_change(platform_height_delta)
        Global.debug_panel.add_message( \
                "Platform height=%s" % player_latest_platform_height)
    display_height = \
            floor(player_max_platform_height / DISPLAY_HEIGHT_INTERVAL) as int
    
    cooldown_indicator.check_for_updates( \
            player_max_platform_height_on_current_life, \
            player_latest_platform_height, \
            !player.surface_state.is_touching_a_surface)
    max_height_indicator.check_for_updates(player_max_platform_height)
    max_height_on_current_height_indicator.check_for_updates( \
            player_max_platform_height_on_current_life)

func _process(delta_sec: float) -> void:
    delta_sec *= Time.physics_framerate_multiplier
    
    if !is_game_playing:
        return
    
    if Global.camera_controller == null:
        return
    
    # Update camera pan, according to auto-scroll speed.
    var camera_displacement_for_frame := camera_speed * delta_sec
    current_camera_height += camera_displacement_for_frame
    camera_position.y -= camera_displacement_for_frame
    
    # Update camera pan, to never be too far below the player.
    if current_camera_height < \
            player_current_height - \
            camera_max_distance_below_player_with_default_zoom * camera_zoom:
        var additional_offset := \
                player_current_height - \
                camera_max_distance_below_player_with_default_zoom * \
                        camera_zoom - \
                current_camera_height
        current_camera_height += additional_offset
        camera_position.y -= additional_offset
    
    Global.camera_controller.offset.y = floor(camera_position.y)
    
    # Update score displays.
    score_boards.set_tier_ratio( \
            current_tier_index + 1, \
            LevelConfig.LEVELS[level_id].tiers.size())
    score_boards.set_height(display_height)
    score_boards.set_score(score)
    score_boards.set_multiplier(cooldown_indicator.multiplier)
    score_boards.set_speed(speed_index + 1)
    score_boards.set_lives(lives_count)
    
    # Check for game over.
    current_fall_height = \
            current_camera_height - \
            player_max_distance_below_camera_with_default_zoom * camera_zoom
    if player_current_height < current_fall_height:
        _fall()
    
    if player == null or \
            player.is_stuck:
        return
    
    if !is_camera_post_stuck_state_tween_active:
        if camera_horizontally_locked:
            camera_position.x = camera_horizontal_lock_tween_displacement
        else:
            camera_position.x = \
                    player.position.x + \
                    camera_horizontal_lock_tween_displacement
        Global.camera_controller.offset.x = floor(camera_position.x)
    
    fog_screen.player_position = player.position

func _fall() -> void:
    falls_count += 1
    lives_count -= 1
    tiers_count_since_falling = 0
    player_max_height_on_current_life = 0.0
    player_latest_platform_height = 0.0
    player_max_platform_height_on_current_life = 0.0
    Global.falls_count_since_reaching_level_end += 1
    cooldown_indicator.stop_cooldown()
    
    Audio.game_over_sfx_player.play()
    
    if lives_count > 0:
        var current_tier_position := current_tier.position
        
        _destroy_player()
        _destroy_tiers()
        
        # Reset state to replay the level at the latest tier.
        _start_new_tier( \
                current_tier_id, \
                current_tier_position, \
                Audio.current_music_player_index)
        _decrement_speed()
        camera_speed = 0.0
        has_input_been_pressed = false
        is_game_playing = true
        
        # Match player and camera positions to the current tier height.
        player.position.y += current_tier_position.y
        player_current_height = \
                -player.position.y - player.get_player_half_height()
        player_max_height = max(player_max_height, player_current_height)
        player_max_height_on_current_life = \
                max(player_max_height_on_current_life, player_current_height)
        current_camera_height = \
                -CAMERA_START_POSITION_POST_STUCK.y - current_tier_position.y
        camera_position = Vector2(0.0, -current_camera_height)
        Global.camera_controller.offset = Utils.floor_vector(camera_position)
    else:
        is_game_playing = false
        speed_index = 0
        score_boards.set_lives(0)
        $SignAllKeys.visible = false
        pause_button.visible = false
        Audio.on_cross_fade_music_finished()
        _destroy_player()
        var high_score := max( \
                int(score), \
                SaveState.get_high_score_for_level(level_id))
        SaveState.set_high_score_for_level( \
                level_id, \
                high_score)
        
        Audio.current_music_player.stop()
        Audio.game_over_sfx_player.connect( \
                "finished", \
                self, \
                "_on_game_over_sfx_finished")

func _on_game_over_sfx_finished() -> void:
    destroy()
    Audio.cross_fade_music(Audio.MAIN_MENU_MUSIC_PLAYER_INDEX)
    Audio.game_over_sfx_player.disconnect( \
            "finished", \
            self, \
            "_on_game_over_sfx_finished")
    Nav.set_screen_is_open( \
            ScreenType.MAIN_MENU, \
            true)
    Nav.screens[ScreenType.GAME].destroy_level()

func _set_camera_start_position() -> void:
    # Register the current camera, so it's globally accessible.
    camera_position = \
            player.position + CAMERA_START_PLAYER_POSITION_OFFSET_PRE_STUCK
    Global.camera_controller.offset = Utils.floor_vector(camera_position)
    Global.camera_controller.zoom = CAMERA_START_ZOOM_PRE_STUCK
    
    peep_hole_size = PEEP_HOLE_SIZE_PRE_STUCK
    fog_screen_opacity = FOG_SCREEN_OPACITY_PRE_STUCK
    fog_screen_color = FOG_SCREEN_COLOR_PRE_STUCK
    _update_fog_screen( \
            peep_hole_size, \
            fog_screen_opacity, \
            fog_screen_color)

func _set_camera_post_stuck_state(animates: bool) -> void:
    peep_hole_size = PEEP_HOLE_SIZE_POST_STUCK
    fog_screen_opacity = FOG_SCREEN_OPACITY_POST_STUCK
    fog_screen_color = FOG_SCREEN_COLOR_POST_STUCK
    
    if animates:
        var tween := Tween.new()
        add_child(tween)
        tween.interpolate_method( \
                self, \
                "_interpolate_camera_to_post_stuck_state", \
                0.0, \
                1.0, \
                CAMERA_PAN_TO_POST_STUCK_DURATION_SEC, \
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
    var start_offset := \
            player.position + CAMERA_START_PLAYER_POSITION_OFFSET_PRE_STUCK - \
            CAMERA_START_POSITION_POST_STUCK
    var end_offset := Vector2.ZERO
    var current_offset: Vector2 = lerp(start_offset, end_offset, progress)
    camera_position = Vector2(0.0, -current_camera_height) + current_offset
    Global.camera_controller.offset = Utils.floor_vector(camera_position)
    
    # Update camera zoom.
    var start_zoom := CAMERA_START_ZOOM_PRE_STUCK
    var end_zoom := camera_zoom
    var current_zoom: float = lerp(start_zoom, end_zoom, progress)
    Global.camera_controller.zoom = current_zoom
    
    # Update peep hole screen (size and opacity).
    var current_peep_hole_size: Vector2 = lerp( \
            PEEP_HOLE_SIZE_PRE_STUCK, \
            PEEP_HOLE_SIZE_POST_STUCK, \
            progress)
    var current_screen_opacity: float = lerp( \
            FOG_SCREEN_OPACITY_PRE_STUCK, \
            FOG_SCREEN_OPACITY_POST_STUCK, \
            progress)
    var current_screen_color: Color = lerp( \
            FOG_SCREEN_COLOR_PRE_STUCK, \
            FOG_SCREEN_COLOR_POST_STUCK, \
            progress)
    _update_fog_screen( \
            current_peep_hole_size, \
            current_screen_opacity, \
            current_screen_color)

func _on_camera_post_stuck_state_completed( \
        _object: Object, \
        _key: NodePath) -> void:
    is_camera_post_stuck_state_tween_active = false

func _add_player(is_base_tier := false) -> void:
    player = Utils.add_scene( \
            self, \
            PLAYER_RESOURCE_PATH, \
            true, \
            true)
    player.position = \
            current_tier.get_player_spawn_position() + \
            TuberPlayer.PLAYER_STUCK_ANIMATION_CENTER_OFFSET
    player.velocity = PLAYER_START_VELOCITY
    player.is_stuck = is_base_tier
    player.on_new_tier()
    
    _set_camera_start_position()
    if !is_base_tier:
        _set_camera_post_stuck_state(false)
    
    mobile_control_ui = MobileControlUI.new(Global.mobile_control_version)
    Global.canvas_layers.hud_layer.add_child(mobile_control_ui)
    mobile_control_ui.update_displays()

func _release_player() -> void:
    assert(player.is_stuck)
    player.is_stuck = false
    _set_camera_post_stuck_state(true)

func _destroy_player() -> void:
    if player != null:
        player.queue_free()
        remove_child(player)
        player = null
    if mobile_control_ui != null:
        mobile_control_ui.destroy()
        mobile_control_ui.queue_free()
        Global.canvas_layers.hud_layer.remove_child(mobile_control_ui)
        mobile_control_ui = null

func _destroy_tiers() -> void:
    if previous_tier != null:
        previous_tier.queue_free()
        remove_child(previous_tier)
    if current_tier != null:
        current_tier.queue_free()
        remove_child(current_tier)
    if next_tier != null:
        next_tier.queue_free()
        remove_child(next_tier)
    if previous_tier_gap != null:
        previous_tier_gap.queue_free()
        remove_child(previous_tier_gap)
    if next_tier_gap != null:
        next_tier_gap.queue_free()
        remove_child(next_tier_gap)

func destroy() -> void:
    Global.level = null
    
    current_tier_id = ""
    is_game_playing = false
    has_input_been_pressed = false
    player_current_height = 0.0
    player_max_height = 0.0
    player_max_height_on_current_life = 0.0
    player_latest_platform_height = 0.0
    player_max_platform_height = 0.0
    player_max_platform_height_on_current_life = 0.0
    display_height = 0
    tier_count = 0
    speed_index = 0
    tiers_count_since_falling = 0
    
    _destroy_player()
    _destroy_tiers()
    
    $SignAllKeys.visible = false
    Audio.on_cross_fade_music_finished()
    
    camera_position = CAMERA_START_POSITION_POST_STUCK
    Global.camera_controller.offset = Utils.floor_vector(camera_position)
    Global.camera_controller.animate_to_zoom(CAMERA_START_ZOOM_PRE_STUCK)
    
    if score_boards != null:
        Global.canvas_layers.hud_layer.remove_child(score_boards)
        score_boards.queue_free()
        score_boards = null
    
    if cooldown_indicator != null:
        Global.canvas_layers.hud_layer.remove_child(cooldown_indicator)
        cooldown_indicator.queue_free()
        cooldown_indicator = null
    
    if max_height_indicator != null:
        remove_child(max_height_indicator)
        max_height_indicator.queue_free()
        max_height_indicator = null
    
    if max_height_on_current_height_indicator != null:
        remove_child(max_height_on_current_height_indicator)
        max_height_on_current_height_indicator.queue_free()
        max_height_on_current_height_indicator = null
    
    if pause_button != null:
        remove_child(pause_button)
        pause_button.queue_free()
        pause_button = null
    
    if fog_screen != null:
        remove_child(fog_screen)
        fog_screen.queue_free()
        fog_screen = null

func _start_new_tier( \
        tier_id := START_TIER_ID, \
        tier_position := Vector2.ZERO, \
        music_player_index := Audio.START_MUSIC_INDEX) -> void:
    Audio.current_music_player_index = music_player_index
    
    current_camera_height = -CAMERA_START_POSITION_POST_STUCK.y
    current_fall_height = -INF
    
    start_tier_id = tier_id
    current_tier_id = tier_id
    
    var level_config: Dictionary = LevelConfig.LEVELS[level_id]
    
    if current_tier_id == "0":
        current_tier_index = -1
    else:
        assert(level_config.tiers.has(current_tier_id))
        current_tier_index = level_config.tiers.find(current_tier_id)
    
    var next_tier_index: int = current_tier_index + 1
    if next_tier_index == level_config.tiers.size():
        # Loop back around, and skip the first/base tier.
        next_tier_index = 0
    var next_tier_id: String = level_config.tiers[next_tier_index]
    
    # Current tier.
    var current_tier_position := tier_position
    var current_tier_config: Dictionary = LevelConfig.TIERS[current_tier_id]
    current_tier = Utils.add_scene( \
            self, \
            current_tier_config.scene_path, \
            true, \
            true)
    assert(current_tier.openness_type != OpennessType.UNKNOWN)
    assert(current_tier_id == "0" or \
            LevelConfig.get_tier_size(current_tier).y / \
                    Constants.CELL_SIZE.y >= \
                    Global.LEVEL_MIN_HEIGHT_CELL_COUNT)
    current_tier.position = current_tier_position
    
    # Next tier.
    var next_tier_position: Vector2 = \
            LevelConfig.get_tier_top_position(current_tier)
    var next_tier_config: Dictionary = LevelConfig.TIERS[next_tier_id]
    next_tier = Utils.add_scene( \
            self, \
            next_tier_config.scene_path, \
            true, \
            true)
    assert(next_tier.openness_type != OpennessType.UNKNOWN)
    assert(LevelConfig.get_tier_size(next_tier).y / Constants.CELL_SIZE.y >= \
            Global.LEVEL_MIN_HEIGHT_CELL_COUNT)
    next_tier.position = next_tier_position
    
    # Next tier gap.
    var next_tier_gap_scene_path: String = \
            LevelConfig.get_tier_gap_scene_path( \
                    current_tier.openness_type, \
                    next_tier.openness_type)
    next_tier_gap = Utils.add_scene( \
            self, \
            next_tier_gap_scene_path, \
            true, \
            true)
    next_tier_gap.position = next_tier_position
    
    # Tier-ratio signs.
    if current_tier_ratio_sign != null:
        remove_child(current_tier_ratio_sign)
    if current_tier_id != "0":
        current_tier_ratio_sign = Utils.add_scene( \
                self, \
                TIER_RATIO_SIGN_RESOURCE_PATH, \
                true, \
                true)
        current_tier_ratio_sign.position = \
                current_tier_position - Vector2(0.0, Constants.CELL_SIZE.y)
        current_tier_ratio_sign.text = \
                "%s / %s" % [current_tier_index + 1, level_config.tiers.size()]
    if next_tier_ratio_sign != null:
        remove_child(next_tier_ratio_sign)
    next_tier_ratio_sign = Utils.add_scene( \
            self, \
            TIER_RATIO_SIGN_RESOURCE_PATH, \
            true, \
            true)
    next_tier_ratio_sign.position = \
            next_tier_position - Vector2(0.0, Constants.CELL_SIZE.y)
    next_tier_ratio_sign.text = \
            "%s / %s" % [next_tier_index + 1, level_config.tiers.size()]
    
    if current_tier_id != "0":
        var previous_tier_scene_path: String = \
                LevelConfig.TIER_BLANK_SCENE_PATH
        previous_tier = Utils.add_scene( \
                self, \
                previous_tier_scene_path, \
                true, \
                true)
        var previous_tier_position: Vector2 = \
                current_tier_position - \
                LevelConfig.get_tier_top_position(previous_tier)
        previous_tier.position = previous_tier_position
        
        var previous_tier_gap_scene_path: String = \
                LevelConfig.get_tier_gap_scene_path( \
                        OpennessType.WALLED, \
                        current_tier.openness_type)
        previous_tier_gap = Utils.add_scene( \
                self, \
                previous_tier_gap_scene_path, \
                true, \
                true)
        previous_tier_gap.position = current_tier_position
    
    camera_speed = 0.0
    Time.physics_framerate_multiplier = _get_min_framerate_multiplier()
    _update_zoom(current_tier_id != "0")
    _update_camera_horizontally_locked( \
            current_tier_config.camera_horizontally_locked)
    _update_fog_screen_for_current_tier(current_tier_id == "0")
    _update_windiness()
    
    # Render the basic input instructions sign.
    $SignAllKeys.visible = Global.are_keyboard_controls_shown
    $SignAllKeys.position = INPUT_SIGN_POSITION
    if current_tier_id != "0":
        $SignAllKeys.position.y -= Constants.CELL_SIZE.y
    
    _add_player(tier_id == "0")

func _on_entered_new_tier() -> void:
    tier_count += 1
    tiers_count_since_falling += 1
    
    # Destory the old previous tier.
    if previous_tier != null:
        remove_child(previous_tier)
        previous_tier.queue_free()
    if previous_tier_gap != null:
        remove_child(previous_tier_gap)
        previous_tier_gap.queue_free()
    
    previous_tier = current_tier
    current_tier = next_tier
    previous_tier_gap = next_tier_gap
    
    var level_config: Dictionary = LevelConfig.LEVELS[level_id]
    
    var was_final_tier_completed := false
    current_tier_index += 1
    if current_tier_index == level_config.tiers.size():
        # Loop back around, and skip the first/base tier.
        was_final_tier_completed = true
        current_tier_index = 0
    current_tier_id = level_config.tiers[current_tier_index]
    var next_tier_index := current_tier_index + 1
    if next_tier_index == level_config.tiers.size():
        # Loop back around, and skip the first/base tier.
        next_tier_index = 0
    var next_tier_id: String = level_config.tiers[next_tier_index]
    
    var current_tier_config: Dictionary = LevelConfig.TIERS[current_tier_id]
    
    # Next tier.
    var next_tier_position: Vector2 = \
            LevelConfig.get_tier_top_position(current_tier)
    var next_tier_config: Dictionary = LevelConfig.TIERS[next_tier_id]
    next_tier = Utils.add_scene( \
            self, \
            next_tier_config.scene_path, \
            true, \
            true)
    assert(LevelConfig.get_tier_size(next_tier).y / Constants.CELL_SIZE.y >= \
            Global.LEVEL_MIN_HEIGHT_CELL_COUNT)
    next_tier.position = next_tier_position
    
    # Next tier gap.
    var next_tier_gap_scene_path: String = \
            LevelConfig.get_tier_gap_scene_path( \
                    current_tier.openness_type, \
                    next_tier.openness_type)
    next_tier_gap = Utils.add_scene( \
            self, \
            next_tier_gap_scene_path, \
            true, \
            true)
    next_tier_gap.position = next_tier_position
    
    # Update tier-ratio signs.
    if current_tier_ratio_sign != null:
        remove_child(current_tier_ratio_sign)
    current_tier_ratio_sign = next_tier_ratio_sign
    next_tier_ratio_sign = Utils.add_scene( \
            self, \
            TIER_RATIO_SIGN_RESOURCE_PATH, \
            true, \
            true)
    next_tier_ratio_sign.position = \
            next_tier_position - Vector2(0.0, Constants.CELL_SIZE.y)
    next_tier_ratio_sign.text = \
            "%s / %s" % [next_tier_index + 1, level_config.tiers.size()]
    
    # Maybe play new music.
    if (start_tier_id != "0" or \
            tier_count != 1) and \
            tier_count % NUMBER_OF_LEVELS_PER_MUSIC == 0:
        Audio.current_music_player_index = \
                (Audio.current_music_player_index + 1) % \
                Audio.MUSIC_PLAYERS.size()
        Audio.cross_fade_music(Audio.current_music_player_index)
    
    _increment_speed()
    _update_zoom()
    _update_camera_horizontally_locked( \
            current_tier_config.camera_horizontally_locked)
    _update_fog_screen_for_current_tier(false)
    _update_windiness()
    
    Audio.new_tier_sfx_player.play()
    
    if was_final_tier_completed:
        _on_final_tier_completed()
    
    _update_score_for_tier_change()
    
    player.on_new_tier()

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
    if tier_count > 1:
        speed_index += 1
        speed_index = min(speed_index, MAX_SPEED_INDEX)
    _update_speed()

func _decrement_speed() -> void:
    speed_index -= SPEED_INDEX_DECREMENT_AMOUNT
    speed_index = max(speed_index, 0)
    _update_speed()

func _update_speed() -> void:
    var speed_index_progress := \
            float(speed_index) / float(MAX_SPEED_INDEX)
    # An ease-out curve.
    speed_index_progress = Utils.ease_by_name( \
            speed_index_progress, \
            SPEED_INCREASE_EASING)
    
    var level_config: Dictionary = LevelConfig.LEVELS[level_id]
    var tier_config: Dictionary = LevelConfig.TIERS[current_tier_id]
    
    var level_camera_speed_min: float = \
            level_config.scroll_speed_min if \
            level_config.has("scroll_speed_min") else \
            LevelConfig.DEFAULT_SCROLL_SPEED_MIN
    var level_camera_speed_max: float = \
            level_config.scroll_speed_max if \
            level_config.has("scroll_speed_max") else \
            LevelConfig.DEFAULT_SCROLL_SPEED_MAX
    var level_camera_speed_multiplier: float = \
            level_config.scroll_speed_multiplier if \
            level_config.has("scroll_speed_multiplier") else \
            LevelConfig.DEFAULT_SCROLL_SPEED_MULTIPLIER
    var tier_camera_speed_min: float = \
            tier_config.scroll_speed_min if \
            tier_config.has("scroll_speed_min") else \
            LevelConfig.DEFAULT_SCROLL_SPEED_MIN
    var tier_camera_speed_max: float = \
            tier_config.scroll_speed_max if \
            tier_config.has("scroll_speed_max") else \
            LevelConfig.DEFAULT_SCROLL_SPEED_MAX
    var tier_camera_speed_multiplier: float = \
            tier_config.scroll_speed_multiplier if \
            tier_config.has("scroll_speed_multiplier") else \
            LevelConfig.DEFAULT_SCROLL_SPEED_MULTIPLIER
    
    var camera_speed_min := max(level_camera_speed_min, tier_camera_speed_min)
    var camera_speed_max := min(level_camera_speed_max, tier_camera_speed_max)
    
    camera_speed = lerp( \
            camera_speed_min, \
            camera_speed_max, \
            speed_index_progress)
    camera_speed *= tier_camera_speed_multiplier
    camera_speed *= level_camera_speed_multiplier
    camera_speed = clamp(camera_speed, camera_speed_min, camera_speed_max)
    
    var frame_rate_multiplier_min := _get_min_framerate_multiplier()
    var frame_rate_multiplier_max := _get_max_framerate_multiplier()
    
    Time.physics_framerate_multiplier = lerp( \
            frame_rate_multiplier_min, \
            frame_rate_multiplier_max, \
            speed_index_progress)
    
    Global.debug_panel.add_message( \
            ("Updated speed: " + \
            "index=%s; " + \
            "scroll_speed=%s; " + \
            "frame_rate_mulitplier=%s") % [
                speed_index,
                camera_speed,
                Time.physics_framerate_multiplier,
            ])

func _update_zoom(updates_camera := true) -> void:
    var level_config: Dictionary = LevelConfig.LEVELS[level_id]
    var tier_config: Dictionary = LevelConfig.TIERS[current_tier_id]
    camera_zoom = \
            CameraController.DEFAULT_CAMERA_ZOOM * \
            level_config.zoom_multiplier * \
            tier_config.zoom_multiplier
    if updates_camera:
        Global.camera_controller.animate_to_zoom(camera_zoom)

func _update_camera_horizontally_locked(locked: bool) -> void:
    if camera_horizontally_locked == locked:
        return
    
    camera_horizontally_locked = locked
    
    var start_value: float = \
            Global.camera_controller.offset.x if \
            camera_horizontally_locked else \
            -player.position.x
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

func _update_fog_screen_for_current_tier(is_base_tier: bool) -> void:
    var level_config: Dictionary = LevelConfig.LEVELS[level_id]
    var tier_config: Dictionary = LevelConfig.TIERS[current_tier_id]
    
    var previous_peep_hole_size: Vector2
    var next_peep_hole_size: Vector2
    var previous_fog_screen_opacity: float
    var next_fog_screen_opacity: float
    var previous_fog_screen_color: Color
    var next_fog_screen_color: Color
    if is_base_tier:
        previous_peep_hole_size = Vector2(1024.0, 1024.0)
        next_peep_hole_size = PEEP_HOLE_SIZE_PRE_STUCK
        previous_fog_screen_opacity = 1.0
        next_fog_screen_opacity = FOG_SCREEN_OPACITY_PRE_STUCK
        previous_fog_screen_color = FOG_SCREEN_COLOR_PRE_STUCK
        next_fog_screen_color = FOG_SCREEN_COLOR_PRE_STUCK
    else:
        previous_peep_hole_size = peep_hole_size
        next_peep_hole_size = \
            PEEP_HOLE_SIZE_POST_STUCK * \
            level_config.peep_hole_size_multiplier * \
            tier_config.peep_hole_size_multiplier
        previous_fog_screen_opacity = fog_screen_opacity
        next_fog_screen_opacity = \
                FOG_SCREEN_OPACITY_POST_STUCK * \
                level_config.fog_screen_opacity_multiplier * \
                tier_config.fog_screen_opacity_multiplier
        
        previous_fog_screen_color = fog_screen_color
        
        var default_color_weight: float
        var level_color_weight: float
        var tier_color_weight: float
        var level_tier_color_weight_sum: float = \
                level_config.fog_screen_color_weight + \
                tier_config.fog_screen_color_weight
        if level_tier_color_weight_sum > 1.0:
            default_color_weight = 0.0
            level_color_weight = \
                    level_config.fog_screen_color_weight / \
                    level_tier_color_weight_sum
            tier_color_weight = \
                    tier_config.fog_screen_color_weight / \
                    level_tier_color_weight_sum
        else:
            default_color_weight = 1.0 - level_tier_color_weight_sum
        var h: float = \
                FOG_SCREEN_COLOR_POST_STUCK.h * default_color_weight + \
                level_config.fog_screen_color.h * level_color_weight + \
                tier_config.fog_screen_color.h * tier_color_weight
        var s: float = \
                FOG_SCREEN_COLOR_POST_STUCK.s * default_color_weight + \
                level_config.fog_screen_color.s * level_color_weight + \
                tier_config.fog_screen_color.s * tier_color_weight
        var v: float = \
                FOG_SCREEN_COLOR_POST_STUCK.v * default_color_weight + \
                level_config.fog_screen_color.v * level_color_weight + \
                tier_config.fog_screen_color.v * tier_color_weight
        next_fog_screen_color = Color.from_hsv(h, s, v, 1.0)
    
    next_peep_hole_size.x = max(next_peep_hole_size.x, 0.0)
    next_peep_hole_size.y = max(next_peep_hole_size.y, 0.0)
    next_fog_screen_opacity = clamp( \
            next_fog_screen_opacity, \
            0.0, \
            1.0)
    
    peep_hole_size_tween.stop(self)
    peep_hole_size_tween.interpolate_method( \
            self, \
            "_interpolate_peep_hole_size", \
            previous_peep_hole_size, \
            next_peep_hole_size, \
            CameraController.ZOOM_ANIMATION_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT)
    peep_hole_size_tween.start()
    
    fog_screen_opacity_tween.stop(self)
    fog_screen_opacity_tween.interpolate_method( \
            self, \
            "_interpolate_fog_screen_opacity", \
            previous_fog_screen_opacity, \
            next_fog_screen_opacity, \
            CameraController.ZOOM_ANIMATION_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT)
    fog_screen_opacity_tween.start()
    
    fog_screen_color_tween.stop(self)
    fog_screen_color_tween.interpolate_method( \
            self, \
            "_interpolate_fog_screen_color", \
            previous_fog_screen_color, \
            next_fog_screen_color, \
            CameraController.ZOOM_ANIMATION_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT)
    fog_screen_color_tween.start()

func _interpolate_peep_hole_size(size: Vector2) -> void:
    peep_hole_size = size
    _update_fog_screen( \
            peep_hole_size, \
            fog_screen_opacity, \
            fog_screen_color)

func _interpolate_fog_screen_opacity(opacity: float) -> void:
    fog_screen_opacity = opacity
    _update_fog_screen( \
            peep_hole_size, \
            fog_screen_opacity, \
            fog_screen_color)

func _interpolate_fog_screen_color(color: Color) -> void:
    fog_screen_color = color
    _update_fog_screen( \
            peep_hole_size, \
            fog_screen_opacity, \
            fog_screen_color)

func _update_fog_screen( \
        hole_size: Vector2, \
        screen_opacity: float, \
        screen_color: Color) -> void:
    var hole_radius := min(hole_size.x, hole_size.y) * 0.5
    fog_screen.hole_radius = hole_radius
    fog_screen.screen_opacity = screen_opacity
    fog_screen.screen_color = screen_color
    player.update_light_size(hole_size)

func _update_windiness() -> void:
    var level_config: Dictionary = LevelConfig.LEVELS[level_id]
    var tier_config: Dictionary = LevelConfig.TIERS[current_tier_id]
    var previous_windiness := windiness
    var next_windiness: float = \
            DEFAULT_WINDINESS * \
            level_config.windiness_multiplier * \
            tier_config.windiness_multiplier
    
    windiness_tween.stop(self)
    windiness_tween.interpolate_property( \
            self, \
            "windiness", \
            previous_windiness, \
            next_windiness, \
            CameraController.ZOOM_ANIMATION_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT)
    windiness_tween.start()
    
    # FIXME: -------------------------------- Update snow and fires

func _update_score_for_height_change(height_delta_pixels: float) -> void:
    score += \
            height_delta_pixels * \
            SCORE_PER_HEIGHT_PIXELS * \
            cooldown_indicator.multiplier

func _update_score_for_tier_change() -> void:
    var tier_score_for_difficulty := 0.0
    match Global.difficulty_mode:
        DifficultyMode.EASY:
            tier_score_for_difficulty = SCORE_FOR_TIER_FOR_EASY_DIFFICULTY
        DifficultyMode.MODERATE:
            tier_score_for_difficulty = SCORE_FOR_TIER_FOR_MODERATE_DIFFICULTY
        DifficultyMode.HARD:
            tier_score_for_difficulty = SCORE_FOR_TIER_FOR_HARD_DIFFICULTY
        _:
            Utils.error()
    score += tier_score_for_difficulty * cooldown_indicator.multiplier

func _on_final_tier_completed() -> void:
    Global.falls_count_since_reaching_level_end = 0
    # FIXME: ------------------

func update_displays() -> void:
    Global.debug_panel.visible = Global.is_debug_panel_shown
    mobile_control_ui.update_displays()
    $SignAllKeys.visible = Global.are_keyboard_controls_shown
    cooldown_indicator.visible = Global.is_multiplier_cooldown_indicator_shown
    max_height_on_current_height_indicator.visible = \
            Global.is_height_indicator_shown
    max_height_indicator.visible = Global.is_height_indicator_shown
    score_boards.update_displays()
