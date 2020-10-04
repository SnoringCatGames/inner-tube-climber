extends Node2D
class_name Level

const PLAYER_RESOURCE_PATH := "res://src/player/tuber_player.tscn"

const TIER_SCENE_PATHS := [
    "res://src/level/tiers/tier_base.tscn",
    "res://src/level/tiers/tier_1.tscn",
]

const MUSIC_STREAM_0 := \
        preload("res://assets/music/stuck_in_a_crevasse.ogg")
const MUSIC_STREAM_1 := \
        preload("res://assets/music/no_escape_from_the_loop.ogg")
const MUSIC_STREAM_2 := \
        preload("res://assets/music/out_for_a_loop_ride.ogg")
const GAME_OVER_SFX_STREAM := preload("res://assets/sfx/yeti_yell.wav")

const START_LEVEL_INDEX := 0

var MUSIC_PLAYER_0 := AudioStreamPlayer.new()
var MUSIC_PLAYER_1 := AudioStreamPlayer.new()
var MUSIC_PLAYER_2 := AudioStreamPlayer.new()

const CELL_SIZE := Vector2(32.0, 32.0)
const VIEWPORT_SIZE := Vector2(480.0, 480.0)

const PLAYER_START_POSITION := Vector2(96.0, -32.0)
const PLAYER_START_VELOCITY := Vector2(0.0, -150.0)
const PLAYER_HALF_HEIGHT := 19.853
const CAMERA_START_ZOOM_PRE_STUCK := 0.4
const CAMERA_START_POSITION_PRE_STUCK := PLAYER_START_POSITION
const CAMERA_START_POSITION_POST_STUCK := Vector2(0.0, -128.0)
const CAMERA_PAN_TO_POST_STUCK_DURATION_SEC := 0.5
const CAMERA_SPEED_TIER_1 := 10.0
# TODO: Update this to instead be logarithmic.
const CAMERA_PAN_SPEED_PER_TIER_MULTIPLIER := 2.0
const CAMERA_MAX_DISTANCE_BELOW_PLAYER := VIEWPORT_SIZE.y / 4
const PLAYER_MAX_DISTANCE_BELOW_CAMERA := VIEWPORT_SIZE.y / 2 + CELL_SIZE.y / 2

var LEVEL_CONFIGS := [
    {
        tiers = [
            {
                tier_number = 0,
                music_player = MUSIC_PLAYER_0,
            },
            {
                tier_number = 1,
                music_player = MUSIC_PLAYER_1,
            },
            {
                tier_number = 1,
                music_player = MUSIC_PLAYER_2,
            },
        ],
    },
]

var current_level_index: int
var current_tier_index: int

var current_music_player: AudioStreamPlayer
var game_over_sfx_player: AudioStreamPlayer

var previous_tier: Tier
var current_tier: Tier
var next_tier: Tier

var player: TuberPlayer
var player_current_height := 0.0
var player_max_height := 0.0
var tier_count := 0

var current_camera_height := -CAMERA_START_POSITION_POST_STUCK.y
var current_camera_speed := 0.0
var current_game_over_height := -INF
var is_game_paused := false

func _init() -> void:
    for path in TIER_SCENE_PATHS:
        load(path)
    
    _init_audio_players()
    
    start_new_level(START_LEVEL_INDEX)

func _init_audio_players() -> void:
    MUSIC_PLAYER_0.stream = MUSIC_STREAM_0
    add_child(MUSIC_PLAYER_0)
    MUSIC_PLAYER_1.stream = MUSIC_STREAM_1
    add_child(MUSIC_PLAYER_1)
    MUSIC_PLAYER_2.stream = MUSIC_STREAM_2
    add_child(MUSIC_PLAYER_2)
    
    game_over_sfx_player = AudioStreamPlayer.new()
    game_over_sfx_player.stream = GAME_OVER_SFX_STREAM
    add_child(game_over_sfx_player)

func _enter_tree() -> void:
    Global.current_level = self

func _ready() -> void:
    current_music_player.play()
    _set_camera()
    
    Global.is_level_ready = true

func _physics_process(delta_sec: float) -> void:
    # Only instantiate the player once the user has pressed a movement button.
    if player == null and (Input.is_action_just_pressed("jump") or \
            Input.is_action_just_pressed("move_left") or \
            Input.is_action_just_pressed("move_right")):
        _remove_stuck_animation()
        _add_player()
    
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

func _game_over() -> void:
    is_game_paused = true
    
    remove_child(player)
    player.queue_free()
    
    current_music_player.stop()
    game_over_sfx_player.play()
    game_over_sfx_player.connect( \
            "finished", \
            self, \
            "_on_game_over_sfx_finished")
    
    # FIXME: Trigger some sort of animation (shake screen?).

func _on_game_over_sfx_finished() -> void:
    # FIXME: Switch to menu, start new music.
    pass

func _set_camera() -> void:
    var camera := Camera2D.new()
    add_child(camera)
    # Register the current camera, so it's globally accessible.
    Global.camera_controller.set_current_camera(camera)
    Global.camera_controller.offset = CAMERA_START_POSITION_PRE_STUCK
    Global.camera_controller.zoom = CAMERA_START_ZOOM_PRE_STUCK

func _set_camera_post_stuck_state() -> void:
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

func _add_player() -> void:
    player = Utils.add_scene( \
            self, \
            PLAYER_RESOURCE_PATH, \
            true, \
            true)
    player.position = PLAYER_START_POSITION
    player.velocity = PLAYER_START_VELOCITY
    add_child(player)
    
    _set_camera_post_stuck_state()

func start_new_level(level_index: int) -> void:
    current_level_index = level_index
    current_tier_index = 0
    
    var level_config: Dictionary = LEVEL_CONFIGS[current_level_index]
    assert(level_config.has("tiers") and level_config.tiers.size() > 1)
    var current_tier_config: Dictionary = \
            level_config.tiers[current_tier_index]
    var next_tier_config: Dictionary = \
            level_config.tiers[current_tier_index + 1]
    
    assert(current_tier_config.has("tier_number") and \
            current_tier_config.tier_number == 0)
    assert(current_tier_config.has("music_player"))
    assert(next_tier_config.has("tier_number") and \
            next_tier_config.tier_number != 0)
    
    var current_tier_scene_path: String = TIER_SCENE_PATHS[0]
    var next_tier_scene_path: String = \
            TIER_SCENE_PATHS[next_tier_config.tier_number]
    
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
    
    current_music_player = current_tier_config.music_player

func _on_entered_new_tier() -> void:
    tier_count += 1
    
    # Destory the old previous tier.
    if previous_tier != null:
        remove_child(previous_tier)
        previous_tier.queue_free()
    
    previous_tier = current_tier
    current_tier = next_tier
    
    var level_config: Dictionary = LEVEL_CONFIGS[current_level_index]
    current_tier_index += 1
    if current_tier_index == level_config.tiers.size():
        # Loop back around, and skip the first/base tier.
        current_tier_index = 1
    var next_tier_index := current_tier_index + 1
    if next_tier_index == level_config.tiers.size():
        # Loop back around, and skip the first/base tier.
        next_tier_index = 1
    
    var current_tier_config: Dictionary = \
            level_config.tiers[current_tier_index]
    var next_tier_config: Dictionary = \
            level_config.tiers[next_tier_index]
    assert(next_tier_config.has("tier_number") and \
            next_tier_config.tier_number != 0)
    
    var next_tier_scene_path: String = \
            TIER_SCENE_PATHS[next_tier_config.tier_number]
    
    next_tier = Utils.add_scene( \
            self, \
            next_tier_scene_path, \
            true, \
            true)
    
    next_tier.position = _get_tier_top_position(current_tier)
    
    # Maybe play new music.
    if current_tier_config.has("music_player") and \
            current_music_player != current_tier_config.music_player:
        if current_music_player != null:
            current_music_player.stop()
        current_music_player = current_tier_config.music_player
        current_music_player.play()
    
    # Update camera pan speed.
    if tier_count == 1:
        current_camera_speed = CAMERA_SPEED_TIER_1
    else:
        current_camera_speed *= CAMERA_PAN_SPEED_PER_TIER_MULTIPLIER

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
