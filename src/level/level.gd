extends Node2D
class_name Level

const PLAYER_RESOURCE_PATH := "res://src/player/tuber_player.tscn"

const TIER_SCENE_PATHS := [
    "res://src/level/tiers/tier_base.tscn",
    "res://src/level/tiers/tier_1.tscn",
]

const MUSIC_STREAM_1 := preload("res://assets/music/on_a_quest.ogg")

const START_LEVEL_INDEX := 0

var MUSIC_PLAYER_1 := AudioStreamPlayer.new()

const CELL_SIZE := Vector2(32.0, 32.0)
const PLAYER_START_POSITION := Vector2(96.0, -32.0)
const PLAYER_START_VELOCITY := Vector2(0.0, -150.0)
const PLAYER_HALF_HEIGHT := 19.853

var LEVEL_CONFIGS := [
    {
        tiers = [
            {
                tier_number = 0,
                music_player = MUSIC_PLAYER_1,
            },
            {
                tier_number = 1,
                music_player = MUSIC_PLAYER_1,
            },
        ],
    },
]

var current_level_index: int
var current_tier_index: int

var current_music_player: AudioStreamPlayer

var previous_tier: Tier
var current_tier: Tier
var next_tier: Tier

var player: TuberPlayer
var player_current_height := 0.0
var player_max_height := 0.0

# FIXME:
# - On physics process, detect when we've reached a new tier.
#   - Destroy tier-2.
#   - Keep tier-1.
#   - Tier-current should already exist.
#   - Create tier+1.
#   - Check whether we should play a new music piece.

func _init() -> void:
    for path in TIER_SCENE_PATHS:
        load(path)
    
    add_child(MUSIC_PLAYER_1)
    
    start_new_level(START_LEVEL_INDEX)

func _enter_tree() -> void:
    Global.current_level = self

func _ready() -> void:
    current_music_player.play()
    
    Global.is_level_ready = true

func _physics_process(delta_sec: float) -> void:
    # Only instantiate the player once the user has pressed a movement button.
    if player == null and (Input.is_action_just_pressed("jump") or \
            Input.is_action_just_pressed("move_left") or \
            Input.is_action_just_pressed("move_right")):
        _remove_stuck_animation()
        _add_player()
    
    if player == null:
        return
    
    player_current_height = -player.position.y - PLAYER_HALF_HEIGHT
    var next_tier_height := -next_tier.position.y + CELL_SIZE.y
    if player_current_height > next_tier_height:
        _on_entered_new_tier()
    player_max_height = max(player_max_height, player_current_height)

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
    if current_tier_config.has("music_player"):
        if current_music_player != null:
            current_music_player.stop()
        current_music_player = current_tier_config.music_player
        current_music_player.play()

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
