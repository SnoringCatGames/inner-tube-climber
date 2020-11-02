extends Node

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

const SLIPPERY_FRICTION_MULTIPLIER := 0.02
const NON_SLIPPERY_FRICTION_MULTIPLIER := 1.0

const SLIPPERY_TILES := [
    "ice_wall_tile",
    "ice_platform_tile",
]

const DEFAULT_ZOOM_MULTIPLIER := 1.0
const DEFAULT_SCROLL_SPEED_MULTIPLIER := 1.0
const DEFAULT_SCROLL_SPEED_MIN := 20.0
const DEFAULT_SCROLL_SPEED_MAX := 160.0

const FRAMERATE_MULTIPLIER_EASY_MIN := 0.7
const FRAMERATE_MULTIPLIER_EASY_MAX := 1.0
const FRAMERATE_MULTIPLIER_MODERATE_MIN := 1.25
const FRAMERATE_MULTIPLIER_MODERATE_MAX := 1.25
const FRAMERATE_MULTIPLIER_HARD_MIN := 1.25
const FRAMERATE_MULTIPLIER_HARD_MAX := 1.6

const TIERS := {
    "0": {
        scene_path = "res://src/level/tiers/tier_base.tscn",
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = 0.0,
        scroll_speed_min = 0.0,
        scroll_speed_max = 0.0,
    },
    "1": {
        scene_path = "res://src/level/tiers/tier_1.tscn",
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
    },
    "2": {
        scene_path = "res://src/level/tiers/tier_2.tscn",
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
    },
    "3": {
        scene_path = "res://src/level/tiers/tier_3.tscn",
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
    },
    "4": {
        scene_path = "res://src/level/tiers/tier_4.tscn",
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
    },
    "5": {
        scene_path = "res://src/level/tiers/tier_5.tscn",
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
    },
    "6": {
        scene_path = "res://src/level/tiers/tier_6.tscn",
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
    },
    "7": {
        scene_path = "res://src/level/tiers/tier_7.tscn",
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
    },
}

const LEVELS := {
    "1": {
        tiers = ["0", "1", "2", "3", "4", "5", "6", "7"],
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
    },
    "2": {
        tiers = ["0", "3", "5", "6"],
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
    },
}

func _init() -> void:
    for tier in TIERS.values():
        load(tier.scene_path)

static func get_tier_size(tier: Tier) -> Vector2:
    return get_tier_bounding_box(tier).size

static func get_tier_top_position(tier: Tier) -> Vector2:
    var bounding_box := get_tier_bounding_box(tier)
    return Vector2(0.0, bounding_box.position.y)

static func get_tier_bounding_box(tier: Tier) -> Rect2:
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

static func get_tier_gap_scene_path( \
        from_openness_type: int,  \
        to_openness_type: int) -> String:
    return LevelConfig.OPENNESS_TO_TIER_GAP_SCENE_PATH \
            [from_openness_type][to_openness_type]

static func get_friction_for_tile( \
        tile_set: TileSet, \
        tile_id: int) -> float:
    return SLIPPERY_FRICTION_MULTIPLIER if \
            SLIPPERY_TILES.has(tile_set.tile_get_name(tile_id)) else \
            NON_SLIPPERY_FRICTION_MULTIPLIER
