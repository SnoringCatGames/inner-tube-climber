extends Node2D
class_name Level

signal back_to_menu
signal game_over(score)

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

const MUSIC_STREAM_0 := \
        preload("res://assets/music/stuck_in_a_crevasse.ogg")
const MUSIC_STREAM_1 := \
        preload("res://assets/music/no_escape_from_the_loop.ogg")
const MUSIC_STREAM_2 := \
        preload("res://assets/music/out_for_a_loop_ride.ogg")
const GAME_OVER_SFX_STREAM := preload("res://assets/sfx/yeti_yell.wav")
const NEW_TIER_SFX_STREAM := preload("res://assets/sfx/new_tier.wav")

const START_TIER_INDEX := 0
const START_MUSIC_INDEX := 2 # FIXME: LEFT OFF HERE

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

func _ready() -> void:
    # Start playing the default music for the menu screen.
    _cross_fade_music(MAIN_MENU_MUSIC_PLAYER_INDEX)
    
    _set_camera()
    
    Global.is_level_ready = true

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

func stop() -> void:
    _cross_fade_music(MAIN_MENU_MUSIC_PLAYER_INDEX)
    visible = false
    is_game_paused = true

func _physics_process(delta_sec: float) -> void:
    if is_game_paused:
        return
    
    # Only instantiate the player once the user has pressed a movement button.
    if player == null and (Input.is_action_just_pressed("jump") or \
            Input.is_action_just_pressed("move_left") or \
            Input.is_action_just_pressed("move_right")):
        _remove_stuck_animation()
        _add_player(true)
    
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
    $ScoreBoards.position.y = Global.camera_controller.offset.y + 190
    $ScoreBoards/VBoxContainer/ScorePanel/ScoreLabel.text = \
            "Score: %d" % current_score
    $ScoreBoards/VBoxContainer/FallsPanel/FallsLabel.text = \
            "Falls: %d" % falls_count

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
        # FIXME: Trigger some sort of animation (shake screen?).
    
    emit_signal("game_over", game_score)

func _on_game_over_sfx_finished() -> void:
    game_over_sfx_player.disconnect( \
            "finished", \
            self, \
            "_on_game_over_sfx_finished")
    emit_signal("back_to_menu")

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

func _destroy_level() -> void:
    current_tier_index = -INF
    is_game_paused = true
    current_score = 0
    
    if player != null:
        player.queue_free()
        remove_child(player)
    if previous_tier != null:
        previous_tier.queue_free()
        remove_child(previous_tier)
    if current_tier != null:
        current_tier.queue_free()
        remove_child(current_tier)
    if next_tier != null:
        next_tier.queue_free()
        remove_child(next_tier)
    
    _on_cross_fade_music_finished()
    $WADSign.visible = false

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
    
    var current_tier_scene_path: String = TIER_SCENE_PATHS[current_tier_index]
    var next_tier_scene_path: String = TIER_SCENE_PATHS[next_tier_index]
    
    current_tier = Utils.add_scene( \
            self, \
            current_tier_scene_path, \
            true, \
            true)
    next_tier = Utils.add_scene( \
            self, \
            next_tier_scene_path, \
            true, \
            true)
    
    current_tier.position = Vector2.ZERO
    next_tier.position = _get_tier_top_position(current_tier)
    
    if current_tier_index != 0:
        current_camera_speed = CAMERA_SPEED_TIER_1
        previous_tier = Utils.add_scene( \
            self, \
            TIER_SCENE_PATHS[0], \
            true, \
            true)
        previous_tier.position.y -= _get_tier_top_position(previous_tier).y
    
    # Render the basic input instructions sign.
    $WADSign.visible = true
    $WADSign.position = INPUT_SIGN_POSITION
    if current_tier_index != 0:
        $WADSign.position.y -= CELL_SIZE.y

func _on_entered_new_tier() -> void:
    tier_count += 1
    
    # Destory the old previous tier.
    if previous_tier != null:
        remove_child(previous_tier)
        previous_tier.queue_free()
    
    previous_tier = current_tier
    current_tier = next_tier
    
    current_tier_index += 1
    if current_tier_index == TIER_SCENE_PATHS.size():
        # Loop back around, and skip the first/base tier.
        current_tier_index = 1
    var next_tier_index := current_tier_index + 1
    if next_tier_index == TIER_SCENE_PATHS.size():
        # Loop back around, and skip the first/base tier.
        next_tier_index = 1
    
    var next_tier_scene_path: String = TIER_SCENE_PATHS[next_tier_index]
    
    next_tier = Utils.add_scene( \
            self, \
            next_tier_scene_path, \
            true, \
            true)
    
    next_tier.position = _get_tier_top_position(current_tier)
    
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

static func _get_tier_top_position(tier: Tier) -> Vector2:
    var tile_maps := Utils.get_children_by_type( \
            tier, \
            TileMap)
    assert(tile_maps.size() == 3)
    
    var bounding_box: Rect2 = \
            Geometry.get_tile_map_bounds_in_world_coordinates(tile_maps[0])
    bounding_box = bounding_box.merge( \
            Geometry.get_tile_map_bounds_in_world_coordinates(tile_maps[1]))
    bounding_box = bounding_box.merge( \
            Geometry.get_tile_map_bounds_in_world_coordinates(tile_maps[2]))
    
    return Vector2(0.0, bounding_box.position.y + tier.position.y)
