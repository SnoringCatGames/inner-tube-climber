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

const FRAMERATE_MULTIPLIER_EASY_MIN := 0.7
const FRAMERATE_MULTIPLIER_EASY_MAX := 1.0
const FRAMERATE_MULTIPLIER_MODERATE_MIN := 1.25
const FRAMERATE_MULTIPLIER_MODERATE_MAX := 1.25
const FRAMERATE_MULTIPLIER_HARD_MIN := 1.25
const FRAMERATE_MULTIPLIER_HARD_MAX := 1.6

const _DEFAULT_TIER_VALUES := {
    camera_horizontally_locked = true,
    zoom_multiplier = 1.0,
    scroll_speed_multiplier = 1.0,
    scroll_speed_min = 20.0,
    scroll_speed_max = 160.0,
    light_energy = {value = 0.6, weight = 0.0},
    peep_hole_size = {value = Vector2(360.0, 360.0), weight = 0.0},
    fog_screen_opacity = {value = 0.0, weight = 0.0},
    fog_screen_secondary_color_opacity_multiplier = {value = 0.4, weight = 0.0},
    fog_screen_primary_color = {value = Color("#ffffff"), weight = 0.0},
    fog_screen_secondary_color = {value = Color("#52c8ff"), weight = 0.0},
    snow_density_multiplier = 1.0,
    windiness = {value = Vector2.ZERO, weight = 0.0},
}

const _DEFAULT_LEVEL_VALUES := {
    lives_count = 3,
    zoom_multiplier = null,
    scroll_speed_multiplier = null,
    scroll_speed_min = null,
    scroll_speed_max = null,
    light_energy = null,
    peep_hole_size = null,
    fog_screen_opacity = null,
    fog_screen_secondary_color_opacity_multiplier = null,
    fog_screen_primary_color = null,
    fog_screen_secondary_color = null,
    snow_density_multiplier = null,
    windiness = null,
}

const _TIERS := {
    "0": {
        scene_path = "res://src/level/tiers/tier_base.tscn",
        scroll_speed_multiplier = 0.0,
        scroll_speed_min = 0.0,
        scroll_speed_max = 0.0,
    },
    "1": {
        scene_path = "res://src/level/tiers/tier_1.tscn",
    },
    "2": {
        scene_path = "res://src/level/tiers/tier_2.tscn",
    },
    "3": {
        scene_path = "res://src/level/tiers/tier_3.tscn",
    },
    "4": {
        scene_path = "res://src/level/tiers/tier_4.tscn",
    },
    "5": {
        scene_path = "res://src/level/tiers/tier_5.tscn",
    },
    "6": {
        scene_path = "res://src/level/tiers/tier_6.tscn",
    },
    "7": {
        scene_path = "res://src/level/tiers/tier_7.tscn",
    },
}

const _LEVELS := {
    "1": {
        tiers = ["1", "2", "3", "4", "5", "6", "7"],
    },
    "2": {
        tiers = ["6", "3"],
    },
}

const _inflated_tiers := {}
const _inflated_levels := {}

var BASE_TIER: Dictionary = get_tier_config("0")

func _init() -> void:
    for tier in _TIERS.values():
        load(tier.scene_path)

static func get_tier_config(tier_id: String) -> Dictionary:
    if _inflated_tiers.has(tier_id):
        return _inflated_tiers[tier_id]
    
    assert(_TIERS.has(tier_id))
    var tier_config: Dictionary = _TIERS[tier_id].duplicate()
    assert(tier_config.has("scene_path"))
    for key in _DEFAULT_TIER_VALUES.keys():
        if !tier_config.has(key):
            tier_config[key] = _DEFAULT_TIER_VALUES[key]
    _inflated_tiers[tier_id] = tier_config
    return tier_config

static func get_level_config(level_id: String) -> Dictionary:
    if _inflated_levels.has(level_id):
        return _inflated_levels[level_id]
    
    assert(_LEVELS.has(level_id))
    var level_config: Dictionary = _LEVELS[level_id].duplicate()
    assert(level_config.has("tiers"))
    for key in _DEFAULT_LEVEL_VALUES.keys():
        if !level_config.has(key):
            var value = _DEFAULT_LEVEL_VALUES[key]
            if value == null:
                value = _DEFAULT_TIER_VALUES[key]
            level_config[key] = value
    _inflated_levels[level_id] = level_config
    return level_config

static func get_value( \
        level_id: String, \
        tier_id: String, \
        key: String):
    var level_config: Dictionary = get_level_config(level_id)
    var tier_config: Dictionary = get_tier_config(tier_id)
    match key:
        "camera_horizontally_locked":
            return tier_config[key]
        "lives_count":
            return level_config[key]
        "zoom_multiplier", \
        "scroll_speed_multiplier", \
        "snow_density_multiplier":
            return level_config[key] * tier_config[key]
        "light_energy", \
        "peep_hole_size", \
        "fog_screen_opacity", \
        "fog_screen_secondary_color_opacity_multiplier", \
        "windiness":
            return Utils.mix([ \
                    level_config[key].value,
                    tier_config[key].value,
                ], [\
                    level_config[key].weight,
                    tier_config[key].weight,
                ])
        "fog_screen_primary_color", \
        "fog_screen_secondary_color":
            return Utils.mix_colors([ \
                    level_config[key].value,
                    tier_config[key].value,
                ], [\
                    level_config[key].weight,
                    tier_config[key].weight,
                ])
        "scroll_speed_min":
            return max(tier_config[key], level_config[key])
        "scroll_speed_max":
            return min(tier_config[key], level_config[key])
        _:
            Utils.error()

static func get_level_ids() -> Array:
    return _LEVELS.keys()

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
