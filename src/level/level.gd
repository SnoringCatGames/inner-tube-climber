extends Node2D
class_name Level

const MUSIC_STREAM_0 := \
        preload("res://assets/music/stuck_in_a_crevasse.ogg")
const MUSIC_STREAM_1 := \
        preload("res://assets/music/no_escape_from_the_loop.ogg")
const MUSIC_STREAM_2 := \
        preload("res://assets/music/out_for_a_loop_ride.ogg")
const GAME_OVER_SFX_STREAM := preload("res://assets/sfx/yeti_yell.wav")
const NEW_TIER_SFX_STREAM := preload("res://assets/sfx/new_tier.wav")

const MOBILE_CONTROL_UI_RESOURCE_PATH := "res://src/mobile_control_ui.tscn"
const SCORE_BOARDS_RESOURCE_PATH := "res://src/score_boards.tscn"

const PLAYER_RESOURCE_PATH := "res://src/player/tuber_player.tscn"

const TIER_SCENE_PATHS := [
    "res://src/level/tiers/tier_base.tscn",
    "res://src/level/tiers/tier_1.tscn",
    "res://src/level/tiers/tier_2.tscn",
    "res://src/level/tiers/tier_3.tscn",
    "res://src/level/tiers/tier_4.tscn",
    "res://src/level/tiers/tier_5.tscn",
    "res://src/level/tiers/tier_6.tscn",
    "res://src/level/tiers/tier_7.tscn",
#    "res://src/level/tiers/tier_8.tscn",
#    "res://src/level/tiers/tier_9.tscn",
]
const TIER_BLANK_SCENE_PATH := "res://src/level/tiers/tier_blank.tscn"

const TIER_GAP_OPEN_TO_OPEN_SCENE_PATH := \
        "res://src/level/tier_gaps/tier_gap_open_to_open.tscn"
const TIER_GAP_OPEN_TO_WALLED_SCENE_PATH := \
        "res://src/level/tier_gaps/tier_gap_open_to_walled.tscn"
const TIER_GAP_OPEN_TO_WALLED_LEFT_SCENE_PATH := \
        "res://src/level/tier_gaps/tier_gap_open_to_walled_left.tscn"
const TIER_GAP_OPEN_TO_WALLED_RIGHT_SCENE_PATH := \
        "res://src/level/tier_gaps/tier_gap_open_to_walled_right.tscn"

const TIER_GAP_WALLED_TO_OPEN_SCENE_PATH := \
        "res://src/level/tier_gaps/tier_gap_walled_to_open.tscn"
const TIER_GAP_WALLED_TO_WALLED_SCENE_PATH := \
        "res://src/level/tier_gaps/tier_gap_walled_to_walled.tscn"
const TIER_GAP_WALLED_TO_WALLED_LEFT_SCENE_PATH := \
        "res://src/level/tier_gaps/tier_gap_walled_to_walled_left.tscn"
const TIER_GAP_WALLED_TO_WALLED_RIGHT_SCENE_PATH := \
        "res://src/level/tier_gaps/tier_gap_walled_to_walled_right.tscn"

const TIER_GAP_WALLED_LEFT_TO_OPEN_SCENE_PATH := \
        "res://src/level/tier_gaps/tier_gap_walled_left_to_open.tscn"
const TIER_GAP_WALLED_LEFT_TO_WALLED_SCENE_PATH := \
        "res://src/level/tier_gaps/tier_gap_walled_left_to_walled.tscn"
const TIER_GAP_WALLED_LEFT_TO_WALLED_LEFT_SCENE_PATH := \
        "res://src/level/tier_gaps/tier_gap_walled_left_to_walled_left.tscn"
const TIER_GAP_WALLED_LEFT_TO_WALLED_RIGHT_SCENE_PATH := \
        "res://src/level/tier_gaps/tier_gap_walled_left_to_walled_right.tscn"

const TIER_GAP_WALLED_RIGHT_TO_OPEN_SCENE_PATH := \
        "res://src/level/tier_gaps/tier_gap_walled_right_to_open.tscn"
const TIER_GAP_WALLED_RIGHT_TO_WALLED_SCENE_PATH := \
        "res://src/level/tier_gaps/tier_gap_walled_right_to_walled.tscn"
const TIER_GAP_WALLED_RIGHT_TO_WALLED_LEFT_SCENE_PATH := \
        "res://src/level/tier_gaps/tier_gap_walled_right_to_walled_left.tscn"
const TIER_GAP_WALLED_RIGHT_TO_WALLED_RIGHT_SCENE_PATH := \
        "res://src/level/tier_gaps/tier_gap_walled_right_to_walled_right.tscn"

const SLIPPERY_FRICTION_MULTIPLIER := 0.02
const NON_SLIPPERY_FRICTION_MULTIPLIER := 1.0

const SLIPPERY_TILES := [
    "ice_wall_tile",
    "ice_platform_tile",
]

const START_TIER_INDEX := 0
const START_MUSIC_INDEX := 0

var MUSIC_PLAYERS = [
    AudioStreamPlayer.new(),
    AudioStreamPlayer.new(),
    AudioStreamPlayer.new(),
]

const CELL_SIZE := Vector2(32.0, 32.0)
const VIEWPORT_SIZE := Vector2(480.0, 480.0)
const INPUT_SIGN_POSITION := Vector2(0.0, 10.0)

const PLAYER_START_POSITION := Vector2(96.0, -32.0)
const PLAYER_START_VELOCITY := Vector2(0.0, -300.0)
const PLAYER_HALF_HEIGHT := 19.853
const CAMERA_START_ZOOM_PRE_STUCK := 0.4
const CAMERA_START_POSITION_PRE_STUCK := PLAYER_START_POSITION
const CAMERA_START_POSITION_POST_STUCK := Vector2(0.0, -128.0)
const CAMERA_PAN_TO_POST_STUCK_DURATION_SEC := 0.5
const CAMERA_SPEED_TIER_1 := 15.0
# TODO: Update this to instead be logarithmic.
const CAMERA_PAN_SPEED_PER_TIER_MULTIPLIER := 3.0
const CAMERA_MAX_DISTANCE_BELOW_PLAYER := VIEWPORT_SIZE.y / 4
const PLAYER_MAX_DISTANCE_BELOW_CAMERA := VIEWPORT_SIZE.y / 2 + CELL_SIZE.y / 2
const MUSIC_CROSS_FADE_DURATION_SEC := 2.0
const MUSIC_SILENT_VOLUME_DB := -80.0
const MAIN_MENU_MUSIC_PLAYER_INDEX := 2
const NUMBER_OF_LEVELS_PER_MUSIC := 1

var is_stuck_in_a_retry_loop := false

var mobile_control_ui: MobileControlUI
var score_boards: ScoreBoards

var start_tier_index := START_TIER_INDEX
var current_tier_index := START_TIER_INDEX
var current_music_player_index := START_MUSIC_INDEX

var previous_music_player: AudioStreamPlayer
var current_music_player: AudioStreamPlayer
var game_over_sfx_player: AudioStreamPlayer
var new_tier_sfx_player: AudioStreamPlayer

var fade_out_tween: Tween
var fade_in_tween: Tween

var previous_tier: Tier
var current_tier: Tier
var next_tier: Tier
var previous_tier_gap: TierGap
var next_tier_gap: TierGap

var player: TuberPlayer
var player_current_height := 0.0
var player_max_height := 0.0
var tier_count := 0
var current_score: int = 0
var falls_count := 0

var current_camera_height := -CAMERA_START_POSITION_POST_STUCK.y
var current_camera_speed := 0.0
var current_game_over_height := -INF
var is_game_paused := true

func _init() -> void:
    for path in TIER_SCENE_PATHS:
        load(path)
    
    _init_audio_players()

func _init_audio_players() -> void:
    MUSIC_PLAYERS[0].stream = MUSIC_STREAM_0
    MUSIC_PLAYERS[0].volume_db = -0.0
    add_child(MUSIC_PLAYERS[0])
    MUSIC_PLAYERS[1].stream = MUSIC_STREAM_1
    MUSIC_PLAYERS[1].volume_db = -0.0
    add_child(MUSIC_PLAYERS[1])
    MUSIC_PLAYERS[2].stream = MUSIC_STREAM_2
    MUSIC_PLAYERS[2].volume_db = -0.0
    add_child(MUSIC_PLAYERS[2])
    
    game_over_sfx_player = AudioStreamPlayer.new()
    game_over_sfx_player.stream = GAME_OVER_SFX_STREAM
    game_over_sfx_player.volume_db = -6.0
    add_child(game_over_sfx_player)
    
    new_tier_sfx_player = AudioStreamPlayer.new()
    new_tier_sfx_player.stream = NEW_TIER_SFX_STREAM
    new_tier_sfx_player.volume_db = -6.0
    add_child(new_tier_sfx_player)

func _enter_tree() -> void:
    Global.current_level = self
    
    score_boards = Utils.add_scene( \
            Global.canvas_layers.hud_layer, \
            SCORE_BOARDS_RESOURCE_PATH, \
            true, \
            false)

func _ready() -> void:
    # Start playing the default music for the menu screen.
    _cross_fade_music(MAIN_MENU_MUSIC_PLAYER_INDEX)
    
    _set_camera()
    
    Global.emit_signal("level_loaded")

func _input(event: InputEvent) -> void:
    if is_game_paused:
        return
    if player != null:
        return
    
    # Only instantiate the player once the user has pressed a movement button.
    if event.is_action_pressed("jump") or \
            event.is_action_pressed("move_left") or \
            event.is_action_pressed("move_right") or \
            ((event is InputEventMouseButton or \
            event is InputEventScreenTouch) and \
            event.pressed):
        _remove_stuck_animation()
        _add_player(true)

func start(tier_index := START_TIER_INDEX) -> void:
    visible = true
    is_game_paused = false
    falls_count = 0
    start_new_level( \
            tier_index, \
            START_MUSIC_INDEX)
    _cross_fade_music(current_music_player_index)
    if tier_index != 0:
        _add_player(false)
    score_boards.visible = true

func stop() -> void:
    _cross_fade_music(MAIN_MENU_MUSIC_PLAYER_INDEX)
    visible = false
    is_game_paused = true
    score_boards.visible = false

func _physics_process(delta_sec: float) -> void:
    if is_game_paused:
        return
    
    if player == null:
        return
    
    # Keep track of player height.
    player_current_height = -player.position.y - PLAYER_HALF_HEIGHT
    var next_tier_height := -next_tier.position.y + CELL_SIZE.y
    if player_current_height > next_tier_height:
        _on_entered_new_tier()
    player_max_height = max(player_max_height, player_current_height)
    current_score = floor(player_max_height / 10.0) as int

func _process(delta_sec: float) -> void:
    if is_game_paused:
        return
    
    if Global.camera_controller != null:
        # Update camera pan, according to auto-scroll speed.
        var camera_displacement_for_frame := current_camera_speed * delta_sec
        current_camera_height += camera_displacement_for_frame
        Global.camera_controller.offset.y -= camera_displacement_for_frame
        
        # Update camera pan, to never be too far below the player.
        if current_camera_height < \
                player_current_height - CAMERA_MAX_DISTANCE_BELOW_PLAYER:
            var additional_offset := \
                    player_current_height - CAMERA_MAX_DISTANCE_BELOW_PLAYER - \
                    current_camera_height
            current_camera_height += additional_offset
            Global.camera_controller.offset.y -= additional_offset
    
    # Check for game over.
    current_game_over_height = \
            current_camera_height - PLAYER_MAX_DISTANCE_BELOW_CAMERA
    if player_current_height < current_game_over_height:
        _game_over()
    
    # Update score displays.
    score_boards.set_score(current_score)
    score_boards.set_falls(falls_count)

func _game_over() -> void:
    falls_count += 1
    var game_score := current_score
    
    var retry_tier_index := current_tier_index
    var camera_retry_speed := current_camera_speed
    
    _destroy_level()
    player_current_height = -PLAYER_START_POSITION.y + CELL_SIZE.y * 2
    player_max_height = player_current_height
    current_camera_height = player_current_height
    Global.camera_controller.offset = Vector2(0.0, -current_camera_height)
    
    game_over_sfx_player.play()
    
    if is_stuck_in_a_retry_loop:
        # Reset state to replay the level at the latest tier.
        start_new_level( \
                retry_tier_index, \
                current_music_player_index)
        _add_player(false)
        current_camera_speed = camera_retry_speed
        is_game_paused = false
    else:
        Global.camera_controller.offset = CAMERA_START_POSITION_PRE_STUCK
        Global.camera_controller.zoom = CAMERA_START_ZOOM_PRE_STUCK
        current_music_player.stop()
        game_over_sfx_player.connect( \
                "finished", \
                self, \
                "_on_game_over_sfx_finished")
    
    Global.emit_signal("game_over", game_score)

func _on_game_over_sfx_finished() -> void:
    game_over_sfx_player.disconnect( \
            "finished", \
            self, \
            "_on_game_over_sfx_finished")
    Global.emit_signal("go_to_main_menu")

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
    add_child(player)
    
    _set_camera_post_stuck_state(is_base_tier)
    
    if Utils.get_is_mobile_device():
        mobile_control_ui = MobileControlUI.new(Global.MOBILE_CONTROL_VERSION)
        Global.canvas_layers.hud_layer.add_child(mobile_control_ui)

func _destroy_level() -> void:
    current_tier_index = -INF
    is_game_paused = true
    current_score = 0
    
    if player != null:
        player.queue_free()
        remove_child(player)
    if mobile_control_ui != null:
        mobile_control_ui.destroy()
        mobile_control_ui.queue_free()
        Global.canvas_layers.hud_layer.remove_child(mobile_control_ui)
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
    
    _on_cross_fade_music_finished()
    $SignAllKeys.visible = false

func start_new_level( \
        tier_index := 0, \
        music_player_index := START_MUSIC_INDEX) -> void:
    player_current_height = 0.0
    player_max_height = 0.0
    current_score = 0
    tier_count = 0
    current_music_player_index = music_player_index
    
    current_camera_height = -CAMERA_START_POSITION_POST_STUCK.y
    current_camera_speed = 0.0
    current_game_over_height = -INF
    
    start_tier_index = tier_index
    current_tier_index = tier_index
    
    var next_tier_index := current_tier_index + 1
    if next_tier_index == TIER_SCENE_PATHS.size():
        # Loop back around, and skip the first/base tier.
        next_tier_index = 1
    
    var current_tier_position := Vector2.ZERO
    var current_tier_scene_path: String = TIER_SCENE_PATHS[current_tier_index]
    current_tier = Utils.add_scene( \
            self, \
            current_tier_scene_path, \
            true, \
            true)
    assert(current_tier.openness_type != OpennessType.UNKNOWN)
    assert(current_tier_index == 0 or \
            _get_tier_size(current_tier).y / CELL_SIZE.y >= \
                    Global.LEVEL_MIN_HEIGHT_CELL_COUNT)
    current_tier.position = current_tier_position
    
    var next_tier_position := _get_tier_top_position(current_tier)
    var next_tier_scene_path: String = TIER_SCENE_PATHS[next_tier_index]
    next_tier = Utils.add_scene( \
            self, \
            next_tier_scene_path, \
            true, \
            true)
    assert(next_tier.openness_type != OpennessType.UNKNOWN)
    assert(_get_tier_size(next_tier).y / CELL_SIZE.y >= \
            Global.LEVEL_MIN_HEIGHT_CELL_COUNT)
    next_tier.position = next_tier_position
    
    var next_tier_gap_scene_path := _get_tier_gap_scene_path( \
            current_tier.openness_type, \
            next_tier.openness_type)
    next_tier_gap = Utils.add_scene( \
            self, \
            next_tier_gap_scene_path, \
            true, \
            true)
    next_tier_gap.position = next_tier_position
    
    if current_tier_index != 0:
        var previous_tier_scene_path := TIER_BLANK_SCENE_PATH
        previous_tier = Utils.add_scene( \
                self, \
                previous_tier_scene_path, \
                true, \
                true)
        var previous_tier_position := -_get_tier_top_position(previous_tier)
        previous_tier.position = previous_tier_position
        
        var previous_tier_gap_scene_path := _get_tier_gap_scene_path( \
                OpennessType.WALLED, \
                current_tier.openness_type)
        previous_tier_gap = Utils.add_scene( \
                self, \
                previous_tier_gap_scene_path, \
                true, \
                true)
        previous_tier_gap.position = current_tier_position
        
        current_camera_speed = CAMERA_SPEED_TIER_1
    
    if !Utils.get_is_mobile_device():
        # Render the basic input instructions sign.
        $SignAllKeys.visible = true
        $SignAllKeys.position = INPUT_SIGN_POSITION
        if current_tier_index != 0:
            $SignAllKeys.position.y -= CELL_SIZE.y

func _on_entered_new_tier() -> void:
    tier_count += 1
    
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
    
    current_tier_index += 1
    if current_tier_index == TIER_SCENE_PATHS.size():
        # Loop back around, and skip the first/base tier.
        current_tier_index = 1
    var next_tier_index := current_tier_index + 1
    if next_tier_index == TIER_SCENE_PATHS.size():
        # Loop back around, and skip the first/base tier.
        next_tier_index = 1
    
    var next_tier_position := _get_tier_top_position(current_tier)
    var next_tier_scene_path: String = TIER_SCENE_PATHS[next_tier_index]
    next_tier = Utils.add_scene( \
            self, \
            next_tier_scene_path, \
            true, \
            true)
    assert(_get_tier_size(next_tier).y / CELL_SIZE.y >= \
            Global.LEVEL_MIN_HEIGHT_CELL_COUNT)
    next_tier.position = next_tier_position
    
    var next_tier_gap_scene_path := _get_tier_gap_scene_path( \
            current_tier.openness_type, \
            next_tier.openness_type)
    next_tier_gap = Utils.add_scene( \
            self, \
            next_tier_gap_scene_path, \
            true, \
            true)
    next_tier_gap.position = next_tier_position
    
    # Maybe play new music.
    if (start_tier_index != 0 or \
            tier_count != 1) and \
            tier_count % NUMBER_OF_LEVELS_PER_MUSIC == 0:
        current_music_player_index = \
                (current_music_player_index + 1) % MUSIC_PLAYERS.size()
        _cross_fade_music(current_music_player_index)
    
    # Update camera pan speed.
    if tier_count == 1:
        current_camera_speed = CAMERA_SPEED_TIER_1
    else:
        current_camera_speed *= CAMERA_PAN_SPEED_PER_TIER_MULTIPLIER
    
    new_tier_sfx_player.play()

func _cross_fade_music(next_music_player_index: int) -> void:
    if fade_out_tween != null:
        _on_cross_fade_music_finished()
    if previous_music_player != null and previous_music_player.playing:
        # TODO: This shouldn't happen, but it does sometimes.
        pass
    
    var next_music_player: AudioStreamPlayer = \
            MUSIC_PLAYERS[next_music_player_index]
    previous_music_player = current_music_player
    current_music_player = next_music_player
    
    if previous_music_player == current_music_player and \
            current_music_player.playing:
        return
    
    if previous_music_player != null and previous_music_player.playing:
        fade_out_tween = Tween.new()
        add_child(fade_out_tween)
        fade_out_tween.interpolate_property( \
                previous_music_player, \
                "volume_db", \
                0.0, \
                MUSIC_SILENT_VOLUME_DB, \
                MUSIC_CROSS_FADE_DURATION_SEC, \
                Tween.TRANS_QUAD, \
                Tween.EASE_IN)
        fade_out_tween.start()
    
    current_music_player.volume_db = MUSIC_SILENT_VOLUME_DB
    current_music_player.play()
    
    fade_in_tween = Tween.new()
    add_child(fade_in_tween)
    fade_in_tween.interpolate_property( \
            current_music_player, \
            "volume_db", \
            MUSIC_SILENT_VOLUME_DB, \
            0.0, \
            MUSIC_CROSS_FADE_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_OUT)
    fade_in_tween.start()
    
    fade_in_tween.connect( \
            "tween_completed", \
            self, \
            "_on_cross_fade_music_finished")

func _on_cross_fade_music_finished() -> void:
    if fade_out_tween != null:
        remove_child(fade_out_tween)
        fade_out_tween.queue_free()
        fade_out_tween = null
    if fade_in_tween != null:
        remove_child(fade_in_tween)
        fade_in_tween.queue_free()
        fade_in_tween = null
    if previous_music_player != null and \
            previous_music_player != current_music_player:
        previous_music_player.stop()

static func _get_tier_size(tier: Tier) -> Vector2:
    return _get_tier_bounding_box(tier).size

static func _get_tier_top_position(tier: Tier) -> Vector2:
    var bounding_box := _get_tier_bounding_box(tier)
    return Vector2(0.0, bounding_box.position.y)

static func _get_tier_bounding_box(tier: Tier) -> Rect2:
    var tile_maps := Utils.get_children_by_type( \
            tier, \
            TileMap)
    var bounding_box: Rect2 = \
            Geometry.get_tile_map_bounds_in_world_coordinates(tile_maps[0])
    for tile_map in tile_maps:
        bounding_box = bounding_box.merge( \
                Geometry.get_tile_map_bounds_in_world_coordinates(tile_map))
    bounding_box.position += tier.position
    return bounding_box

# Dictionary<OpennessType, Dictionary<OpennessType, String>>
const OPENNESS_TO_TIER_GAP_SCENE_PATH := {
    OpennessType.OPEN_WITHOUT_HORIZONTAL_PAN: {
        OpennessType.OPEN_WITHOUT_HORIZONTAL_PAN: \
                TIER_GAP_OPEN_TO_OPEN_SCENE_PATH,
        OpennessType.OPEN_WITH_HORIZONTAL_PAN: \
                TIER_GAP_OPEN_TO_OPEN_SCENE_PATH,
        OpennessType.WALLED: \
                TIER_GAP_OPEN_TO_WALLED_SCENE_PATH,
        OpennessType.WALLED_LEFT: \
                TIER_GAP_OPEN_TO_WALLED_LEFT_SCENE_PATH,
        OpennessType.WALLED_RIGHT: \
                TIER_GAP_OPEN_TO_WALLED_RIGHT_SCENE_PATH,
    },
    OpennessType.OPEN_WITH_HORIZONTAL_PAN: {
        OpennessType.OPEN_WITHOUT_HORIZONTAL_PAN: \
                TIER_GAP_OPEN_TO_OPEN_SCENE_PATH,
        OpennessType.OPEN_WITH_HORIZONTAL_PAN: \
                TIER_GAP_OPEN_TO_OPEN_SCENE_PATH,
        OpennessType.WALLED: \
                TIER_GAP_OPEN_TO_WALLED_SCENE_PATH,
        OpennessType.WALLED_LEFT: \
                TIER_GAP_OPEN_TO_WALLED_LEFT_SCENE_PATH,
        OpennessType.WALLED_RIGHT: \
                TIER_GAP_OPEN_TO_WALLED_RIGHT_SCENE_PATH,
    },
    OpennessType.WALLED: {
        OpennessType.OPEN_WITHOUT_HORIZONTAL_PAN: \
                TIER_GAP_WALLED_TO_OPEN_SCENE_PATH,
        OpennessType.OPEN_WITH_HORIZONTAL_PAN: \
                TIER_GAP_WALLED_TO_OPEN_SCENE_PATH,
        OpennessType.WALLED: \
                TIER_GAP_WALLED_TO_WALLED_SCENE_PATH,
        OpennessType.WALLED_LEFT: \
                TIER_GAP_WALLED_TO_WALLED_LEFT_SCENE_PATH,
        OpennessType.WALLED_RIGHT: \
                TIER_GAP_WALLED_TO_WALLED_RIGHT_SCENE_PATH,
    },
    OpennessType.WALLED_LEFT: {
        OpennessType.OPEN_WITHOUT_HORIZONTAL_PAN: \
                TIER_GAP_WALLED_LEFT_TO_OPEN_SCENE_PATH,
        OpennessType.OPEN_WITH_HORIZONTAL_PAN: \
                TIER_GAP_WALLED_LEFT_TO_OPEN_SCENE_PATH,
        OpennessType.WALLED: \
                TIER_GAP_WALLED_LEFT_TO_WALLED_SCENE_PATH,
        OpennessType.WALLED_LEFT: \
                TIER_GAP_WALLED_LEFT_TO_WALLED_LEFT_SCENE_PATH,
        OpennessType.WALLED_RIGHT: \
                TIER_GAP_WALLED_LEFT_TO_WALLED_RIGHT_SCENE_PATH,
    },
    OpennessType.WALLED_RIGHT: {
        OpennessType.OPEN_WITHOUT_HORIZONTAL_PAN: \
                TIER_GAP_WALLED_RIGHT_TO_OPEN_SCENE_PATH,
        OpennessType.OPEN_WITH_HORIZONTAL_PAN: \
                TIER_GAP_WALLED_RIGHT_TO_OPEN_SCENE_PATH,
        OpennessType.WALLED: \
                TIER_GAP_WALLED_RIGHT_TO_WALLED_SCENE_PATH,
        OpennessType.WALLED_LEFT: \
                TIER_GAP_WALLED_RIGHT_TO_WALLED_LEFT_SCENE_PATH,
        OpennessType.WALLED_RIGHT: \
                TIER_GAP_WALLED_RIGHT_TO_WALLED_RIGHT_SCENE_PATH,
    },
}

static func _get_tier_gap_scene_path( \
        from_openness_type: int,  \
        to_openness_type: int) -> String:
    return OPENNESS_TO_TIER_GAP_SCENE_PATH[from_openness_type][to_openness_type]

static func get_friction_for_tile( \
        tile_set: TileSet, \
        tile_id: int) -> float:
    return SLIPPERY_FRICTION_MULTIPLIER if \
            SLIPPERY_TILES.has(tile_set.tile_get_name(tile_id)) else \
            NON_SLIPPERY_FRICTION_MULTIPLIER
