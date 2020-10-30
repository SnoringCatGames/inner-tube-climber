extends Node2D
class_name Level

const MOBILE_CONTROL_UI_RESOURCE_PATH := "res://src/mobile_control_ui.tscn"
const SCORE_BOARDS_RESOURCE_PATH := "res://src/score_boards.tscn"

const PLAYER_RESOURCE_PATH := "res://src/player/tuber_player.tscn"

const START_TIER_ID := "0"
const DEFAULT_LIVES_COUNT := 3

const CELL_SIZE := Vector2(32.0, 32.0)
const INPUT_SIGN_POSITION := Vector2(0.0, 10.0)

const PLAYER_START_POSITION := Vector2(96.0, -32.0)
const PLAYER_START_VELOCITY := Vector2(0.0, -300.0)
const PLAYER_HALF_HEIGHT := 19.853
const CAMERA_START_ZOOM_PRE_STUCK := 0.4
const CAMERA_START_POSITION_PRE_STUCK := PLAYER_START_POSITION
const CAMERA_START_POSITION_POST_STUCK := Vector2(0.0, -128.0)
const CAMERA_PAN_TO_POST_STUCK_DURATION_SEC := 0.5
# TODO: Update this to instead be logarithmic.
const CAMERA_PAN_SPEED_PER_TIER_MULTIPLIER := 3.0
const NUMBER_OF_LEVELS_PER_MUSIC := 1

# How many pixels correspond to a single display-height unit. 
const DISPLAY_HEIGHT_INTERVAL := 32.0

# This is how many tiers the player must pass through without falling before
# hitting the max camera scroll speed.
const CAMERA_MAX_SPEED_INDEX := 10

const CAMERA_SPEED_INCREASE_EASING := "linear"

const CAMERA_SPEED_INDEX_DECREMENT_AMOUNT := 2

const SCORE_PER_HEIGHT_PIXELS := 10.0 / 32.0
const SCORE_MULTIPLIER_DELTA_FOR_EASY_DIFFICULTY := -0.15
const SCORE_MULTIPLIER_DELTA_FOR_MODERATE_DIFFICULTY := 0.0
const SCORE_MULTIPLIER_DELTA_FOR_HARD_DIFFICULTY := 0.25
const SCORE_MULTIPLIER_DELTA_PER_LIFE := 0.05

var has_input_been_pressed := false

var camera_speed_index := 0

var camera_max_distance_below_player := INF
var player_max_distance_below_camera := INF

var mobile_control_ui: MobileControlUI
var score_boards: ScoreBoards

var level_id := ""

var start_tier_id := START_TIER_ID
var current_tier_id := START_TIER_ID

var previous_tier: Tier
var current_tier: Tier
var next_tier: Tier
var previous_tier_gap: TierGap
var next_tier_gap: TierGap

var player: TuberPlayer
var player_current_height: float = 0.0
var player_max_height: float = 0.0
var tier_count: int = 0
var display_height: int = 0
var falls_count: int = 0
var lives_count: int = DEFAULT_LIVES_COUNT

var current_camera_height := -CAMERA_START_POSITION_POST_STUCK.y
var camera_speed := 0.0
var current_fall_height := -INF
var is_game_playing := false

# FIXME: --------------------------------
var tiers_count_since_falling := 0
var falls_count_since_reaching_level_end := 0

func _enter_tree() -> void:
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

func _ready() -> void:
    _set_camera()
    set_difficulty(Global.difficulty_mode)

func _input(event: InputEvent) -> void:
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
        if is_game_playing and player == null:
            _remove_stuck_animation()
            _add_player(true)
        
        if current_tier_id != "0":
            camera_speed_index = 0
            _update_camera_speed()

func _handle_display_resize() -> void:
    var game_area_size: Vector2 = Global.get_game_area_region().size
    camera_max_distance_below_player = game_area_size.y / 4
    player_max_distance_below_camera = game_area_size.y / 2 + CELL_SIZE.y / 2

func start( \
        level_id: String, \
        tier_id := START_TIER_ID) -> void:
    self.level_id = level_id
    visible = true
    is_game_playing = true
    falls_count = 0
    _start_new_tier( \
            tier_id, \
            Vector2.ZERO, \
            Audio.START_MUSIC_INDEX)
    Audio.cross_fade_music(Audio.current_music_player_index)
    if tier_id != "0":
        _add_player(false)
    score_boards.visible = true

func _physics_process(delta_sec: float) -> void:
    delta_sec *= Time.physics_framerate_multiplier
    
    if !is_game_playing or \
            player == null:
        return
    
    # Keep track of player height.
    player_current_height = -player.position.y - PLAYER_HALF_HEIGHT
    var next_tier_height := -next_tier.position.y + CELL_SIZE.y
    if player_current_height > next_tier_height:
        _on_entered_new_tier()
    player_max_height = max(player_max_height, player_current_height)
    display_height = floor(player_max_height / DISPLAY_HEIGHT_INTERVAL) as int

func _process(delta_sec: float) -> void:
    delta_sec *= Time.physics_framerate_multiplier
    
    if !is_game_playing:
        return
    
    if Global.camera_controller != null:
        # Update camera pan, according to auto-scroll speed.
        var camera_displacement_for_frame := camera_speed * delta_sec
        current_camera_height += camera_displacement_for_frame
        Global.camera_controller.offset.y -= camera_displacement_for_frame
        
        # Update camera pan, to never be too far below the player.
        if current_camera_height < \
                player_current_height - camera_max_distance_below_player:
            var additional_offset := \
                    player_current_height - camera_max_distance_below_player - \
                    current_camera_height
            current_camera_height += additional_offset
            Global.camera_controller.offset.y -= additional_offset
    
    # Update score displays.
    score_boards.set_height(display_height)
    score_boards.set_lives(lives_count)
    
    # Check for game over.
    current_fall_height = \
            current_camera_height - player_max_distance_below_camera
    if player_current_height < current_fall_height:
        _fall()

func _fall() -> void:
    falls_count += 1
    lives_count -= 1
    tiers_count_since_falling = 0
    falls_count_since_reaching_level_end += 1
    
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
        _decrement_camera_speed()
        _add_player(false)
        is_game_playing = true
        
        # Match player and camera positions to the current tier height.
        player.position.y += current_tier_position.y
        player_current_height = -player.position.y - PLAYER_HALF_HEIGHT
        player_max_height = max(player_max_height, player_current_height)
        current_camera_height = \
                -CAMERA_START_POSITION_POST_STUCK.y - current_tier_position.y
        Global.camera_controller.offset = Vector2(0.0, -current_camera_height)
    else:
        is_game_playing = false
        camera_speed_index = 0
        score_boards.set_lives(0)
        $SignAllKeys.visible = false
        Audio.on_cross_fade_music_finished()
        _destroy_player()
        
        Audio.current_music_player.stop()
        Audio.game_over_sfx_player.connect( \
                "finished", \
                self, \
                "_on_game_over_sfx_finished")

func _on_game_over_sfx_finished() -> void:
    _destroy_level()
    Audio.cross_fade_music(Audio.MAIN_MENU_MUSIC_PLAYER_INDEX)
    Audio.game_over_sfx_player.disconnect( \
            "finished", \
            self, \
            "_on_game_over_sfx_finished")
    Nav.set_screen_is_open( \
            ScreenType.MAIN_MENU, \
            true)

func _set_camera() -> void:
    var camera := Camera2D.new()
    add_child(camera)
    # Register the current camera, so it's globally accessible.
    Global.camera_controller.set_current_camera(camera)
    Global.camera_controller.offset = CAMERA_START_POSITION_PRE_STUCK
    Global.camera_controller.zoom = CAMERA_START_ZOOM_PRE_STUCK

func _set_camera_post_stuck_state(is_base_tier: bool) -> void:
    if is_base_tier:
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
        tween.start()
    else:
        _interpolate_camera_to_post_stuck_state(1.0)

func _interpolate_camera_to_post_stuck_state(progress: float) -> void:
    var start_offset := \
            CAMERA_START_POSITION_PRE_STUCK - CAMERA_START_POSITION_POST_STUCK
    var end_offset := Vector2.ZERO
    var current_offset := start_offset.linear_interpolate(end_offset, progress)
    Global.camera_controller.offset = \
            Vector2(0.0, -current_camera_height) + current_offset
    
    var start_zoom := CAMERA_START_ZOOM_PRE_STUCK
    var end_zoom := CameraController.DEFAULT_CAMERA_ZOOM
    var current_zoom := start_zoom + (end_zoom - start_zoom) * progress
    Global.camera_controller.zoom = current_zoom

func _remove_stuck_animation() -> void:
    # Only the base tier has the stuck-tuber animation.
    if current_tier_id == "0":
        var stuck_animation := current_tier.get_node("TuberStuckAnimation")
        remove_child(stuck_animation)
        stuck_animation.queue_free()

func _add_player(is_base_tier := false) -> void:
    player = Utils.add_scene( \
            self, \
            PLAYER_RESOURCE_PATH, \
            true, \
            true)
    var position := \
            Vector2(0.0, -PLAYER_HALF_HEIGHT - CELL_SIZE.y * 1.5) if \
            !is_base_tier else \
            PLAYER_START_POSITION
    player.position = position
    player.velocity = PLAYER_START_VELOCITY
    
    _set_camera_post_stuck_state(is_base_tier)
    
    if Global.SHOWS_MOBILE_CONTROLS:
        mobile_control_ui = MobileControlUI.new(Global.MOBILE_CONTROL_VERSION)
        Global.canvas_layers.hud_layer.add_child(mobile_control_ui)

func _destroy_player() -> void:
    if player != null:
        player.queue_free()
        remove_child(player)
    if mobile_control_ui != null:
        mobile_control_ui.destroy()
        mobile_control_ui.queue_free()
        Global.canvas_layers.hud_layer.remove_child(mobile_control_ui)

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

func _destroy_level() -> void:
    current_tier_id = ""
    is_game_playing = false
    has_input_been_pressed = false
    player_current_height = 0.0
    player_max_height = 0.0
    display_height = 0
    tier_count = 0
    camera_speed_index = 0
    falls_count_since_reaching_level_end = 0
    tiers_count_since_falling = 0
    
    _destroy_player()
    _destroy_tiers()
    
    score_boards.set_lives(0)
    score_boards.visible = false
    $SignAllKeys.visible = false
    Audio.on_cross_fade_music_finished()
    
    Global.camera_controller.offset = CAMERA_START_POSITION_PRE_STUCK
    Global.camera_controller.zoom = CAMERA_START_ZOOM_PRE_STUCK

func _start_new_tier( \
        tier_id := "0", \
        tier_position := Vector2.ZERO, \
        music_player_index := Audio.START_MUSIC_INDEX) -> void:
    Audio.current_music_player_index = music_player_index
    
    current_camera_height = -CAMERA_START_POSITION_POST_STUCK.y
    current_fall_height = -INF
    
    start_tier_id = tier_id
    current_tier_id = tier_id
    
    var level_config: Dictionary = LevelConfig.LEVELS[level_id]
    
    # FIXME: ----------------
    assert(level_config.tiers.has(current_tier_id))
    var next_tier_index: int = level_config.tiers.find(current_tier_id) + 1
    if next_tier_index == level_config.tiers.size():
        # Loop back around, and skip the first/base tier.
        next_tier_index = 1
    var next_tier_id: String = level_config.tiers[next_tier_index]
    
    var current_tier_position := tier_position
    var current_tier_config: Dictionary = LevelConfig.TIERS[current_tier_id]
    current_tier = Utils.add_scene( \
            self, \
            current_tier_config.scene_path, \
            true, \
            true)
    assert(current_tier.openness_type != OpennessType.UNKNOWN)
    assert(current_tier_id == "0" or \
            LevelConfig.get_tier_size(current_tier).y / CELL_SIZE.y >= \
                    Global.LEVEL_MIN_HEIGHT_CELL_COUNT)
    current_tier.position = current_tier_position
    
    var next_tier_position: Vector2 = \
            LevelConfig.get_tier_top_position(current_tier)
    var next_tier_config: Dictionary = LevelConfig.TIERS[next_tier_id]
    next_tier = Utils.add_scene( \
            self, \
            next_tier_config.scene_path, \
            true, \
            true)
    assert(next_tier.openness_type != OpennessType.UNKNOWN)
    assert(LevelConfig.get_tier_size(next_tier).y / CELL_SIZE.y >= \
            Global.LEVEL_MIN_HEIGHT_CELL_COUNT)
    next_tier.position = next_tier_position
    
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
    
    if !Global.SHOWS_MOBILE_CONTROLS:
        # Render the basic input instructions sign.
        $SignAllKeys.visible = true
        $SignAllKeys.position = INPUT_SIGN_POSITION
        if current_tier_id != "0":
            $SignAllKeys.position.y -= CELL_SIZE.y

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
    
    # FIXME: -------------
    assert(level_config.tiers.has(current_tier_id))
    var current_tier_index: int = level_config.tiers.find(current_tier_id) + 1
    if current_tier_index == level_config.tiers.size():
        # Loop back around, and skip the first/base tier.
        current_tier_index = 1
    current_tier_id = level_config.tiers[current_tier_index]
    var next_tier_index := current_tier_index + 1
    if next_tier_index == level_config.tiers.size():
        # Loop back around, and skip the first/base tier.
        next_tier_index = 1
    var next_tier_id: String = level_config.tiers[next_tier_index]
    
    var next_tier_position: Vector2 = \
            LevelConfig.get_tier_top_position(current_tier)
    var next_tier_config: Dictionary = LevelConfig.TIERS[next_tier_id]
    next_tier = Utils.add_scene( \
            self, \
            next_tier_config.scene_path, \
            true, \
            true)
    assert(LevelConfig.get_tier_size(next_tier).y / CELL_SIZE.y >= \
            Global.LEVEL_MIN_HEIGHT_CELL_COUNT)
    next_tier.position = next_tier_position
    
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
    
    # Maybe play new music.
    if (start_tier_id != "0" or \
            tier_count != 1) and \
            tier_count % NUMBER_OF_LEVELS_PER_MUSIC == 0:
        Audio.current_music_player_index = \
                (Audio.current_music_player_index + 1) % \
                Audio.MUSIC_PLAYERS.size()
        Audio.cross_fade_music(Audio.current_music_player_index)
    
    _increment_camera_speed()
    
    Audio.new_tier_sfx_player.play()

func set_difficulty(difficulty_mode: int) -> void:
    match difficulty_mode:
        DifficultyMode.EASY:
            Time.physics_framerate_multiplier = 0.7
        DifficultyMode.MODERATE:
            Time.physics_framerate_multiplier = 1.0
        DifficultyMode.HARD:
            Time.physics_framerate_multiplier = 1.5
        DifficultyMode.DYNAMIC:
            # FIXME: -------------------------
            Time.physics_framerate_multiplier = 1.0
        _:
            Utils.error()

func _increment_camera_speed() -> void:
    if tier_count > 1:
        camera_speed_index += 1
        camera_speed_index = min(camera_speed_index, CAMERA_MAX_SPEED_INDEX)
    _update_camera_speed()

func _decrement_camera_speed() -> void:
    camera_speed_index -= CAMERA_SPEED_INDEX_DECREMENT_AMOUNT
    camera_speed_index = max(camera_speed_index, 0)
    _update_camera_speed()

func _update_camera_speed() -> void:
    var level_config: Dictionary = LevelConfig.LEVELS[level_id]
    var tier_config: Dictionary = LevelConfig.TIERS[current_tier_id]
    
    var level_speed_min: float = \
            level_config.scroll_speed_min if \
            level_config.has("scroll_speed_min") else \
            LevelConfig.DEFAULT_SCROLL_SPEED_MIN
    var level_speed_max: float = \
            level_config.scroll_speed_max if \
            level_config.has("scroll_speed_max") else \
            LevelConfig.DEFAULT_SCROLL_SPEED_MAX
    var level_speed_multiplier: float = \
            level_config.scroll_speed_multiplier if \
            level_config.has("scroll_speed_multiplier") else \
            LevelConfig.DEFAULT_SCROLL_SPEED_MULTIPLIER
    var tier_speed_min: float = \
            tier_config.scroll_speed_min if \
            tier_config.has("scroll_speed_min") else \
            LevelConfig.DEFAULT_SCROLL_SPEED_MIN
    var tier_speed_max: float = \
            tier_config.scroll_speed_max if \
            tier_config.has("scroll_speed_max") else \
            LevelConfig.DEFAULT_SCROLL_SPEED_MAX
    var tier_speed_multiplier: float = \
            tier_config.scroll_speed_multiplier if \
            tier_config.has("scroll_speed_multiplier") else \
            LevelConfig.DEFAULT_SCROLL_SPEED_MULTIPLIER
    
    var speed_min := max(level_speed_min, tier_speed_min)
    var speed_max := min(level_speed_max, tier_speed_max)
    var speed_index_progress := \
            float(camera_speed_index) / float(CAMERA_MAX_SPEED_INDEX)
    # An ease-out curve.
    speed_index_progress = ease( \
            speed_index_progress, \
            Utils.ease_name_to_param(CAMERA_SPEED_INCREASE_EASING))
    
    camera_speed = speed_min + (speed_max - speed_min) * speed_index_progress
    camera_speed *= tier_speed_multiplier
    camera_speed *= level_speed_multiplier
    camera_speed = clamp(camera_speed, speed_min, speed_max)
    
    Global.debug_panel.add_message( \
            "Updated scroll speed: index=%s; speed=%s" % [
                camera_speed_index,
                camera_speed,
            ])

func _calculate_score_for_height_delta(height_delta_pixels: float) -> float:
#    var score_multiplier_delta_for_tiers_count_since_falling := \
#            0.5 + sqrt(tiers_count_since_falling)
    var score_multiplier_delta_for_tiers_count_since_falling := \
            tiers_count_since_falling * 0.5
    
    var score_multiplier_delta_for_difficulty := 0.0
    match Global.difficulty_mode:
        DifficultyMode.EASY:
            score_multiplier_delta_for_difficulty = \
                    SCORE_MULTIPLIER_DELTA_FOR_EASY_DIFFICULTY
        DifficultyMode.MODERATE:
            score_multiplier_delta_for_difficulty = \
                    SCORE_MULTIPLIER_DELTA_FOR_MODERATE_DIFFICULTY
        DifficultyMode.HARD:
            score_multiplier_delta_for_difficulty = \
                    SCORE_MULTIPLIER_DELTA_FOR_HARD_DIFFICULTY
        _:
            Utils.error()
    
    var score_multiplier_delta_for_lives_count := \
            lives_count * SCORE_MULTIPLIER_DELTA_PER_LIFE
    
    var score_multiplier := \
        1.0 + \
        score_multiplier_delta_for_tiers_count_since_falling + \
        score_multiplier_delta_for_difficulty + \
        score_multiplier_delta_for_lives_count
    
    return height_delta_pixels * SCORE_PER_HEIGHT_PIXELS * score_multiplier
