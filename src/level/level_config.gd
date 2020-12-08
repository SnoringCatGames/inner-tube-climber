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

const DEFAULT_LIVES_COUNT := 3
const DEFAULT_ZOOM_MULTIPLIER := 1.0
const DEFAULT_SCROLL_SPEED_MULTIPLIER := 1.0
const DEFAULT_SCROLL_SPEED_MIN := 20.0
const DEFAULT_SCROLL_SPEED_MAX := 160.0
const DEFAULT_LIGHT_ENERGY_MULTIPLIER := 1.0
const DEFAULT_PEEP_HOLE_SIZE_MULTIPLIER := 1.0
const DEFAULT_FOG_SCREEN_OPACITY := 0.0
const DEFAULT_FOG_SCREEN_OPACITY_WEIGHT := 0.0
const DEFAULT_FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_MULTIPLIER := 1.0
const DEFAULT_FOG_SCREEN_PRIMARY_COLOR := Color("#ffffff")
const DEFAULT_FOG_SCREEN_PRIMARY_COLOR_WEIGHT := 0.0
const DEFAULT_FOG_SCREEN_SECONDARY_COLOR := Color("#ffffff")
const DEFAULT_FOG_SCREEN_SECONDARY_COLOR_WEIGHT := 0.0
const DEFAULT_SNOW_DENSITY_MULTIPLIER := 1.0
const DEFAULT_WINDINESS := Vector2.ZERO

const FRAMERATE_MULTIPLIER_EASY_MIN := 0.7
const FRAMERATE_MULTIPLIER_EASY_MAX := 1.0
const FRAMERATE_MULTIPLIER_MODERATE_MIN := 1.25
const FRAMERATE_MULTIPLIER_MODERATE_MAX := 1.25
const FRAMERATE_MULTIPLIER_HARD_MIN := 1.25
const FRAMERATE_MULTIPLIER_HARD_MAX := 1.6

const TIERS := {
    "0": {
        scene_path = "res://src/level/tiers/tier_base.tscn",
        camera_horizontally_locked = true,
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = 0.0,
        scroll_speed_min = 0.0,
        scroll_speed_max = 0.0,
        light_energy_multiplier = DEFAULT_LIGHT_ENERGY_MULTIPLIER,
        peep_hole_size_multiplier = DEFAULT_PEEP_HOLE_SIZE_MULTIPLIER,
        fog_screen_opacity = DEFAULT_FOG_SCREEN_OPACITY,
        fog_screen_opacity_weight = DEFAULT_FOG_SCREEN_OPACITY_WEIGHT,
        fog_screen_secondary_color_opacity_multiplier_multiplier = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_MULTIPLIER,
        fog_screen_primary_color = DEFAULT_FOG_SCREEN_PRIMARY_COLOR,
        fog_screen_primary_color_weight = \
                DEFAULT_FOG_SCREEN_PRIMARY_COLOR_WEIGHT,
        fog_screen_secondary_color = DEFAULT_FOG_SCREEN_SECONDARY_COLOR,
        fog_screen_secondary_color_weight = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_WEIGHT,
        snow_density_multiplier = DEFAULT_SNOW_DENSITY_MULTIPLIER,
        windiness = DEFAULT_WINDINESS,
    },
    "1": {
        scene_path = "res://src/level/tiers/tier_1.tscn",
        camera_horizontally_locked = true,
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
        light_energy_multiplier = DEFAULT_LIGHT_ENERGY_MULTIPLIER,
        peep_hole_size_multiplier = DEFAULT_PEEP_HOLE_SIZE_MULTIPLIER,
        fog_screen_opacity = DEFAULT_FOG_SCREEN_OPACITY,
        fog_screen_opacity_weight = DEFAULT_FOG_SCREEN_OPACITY_WEIGHT,
        fog_screen_secondary_color_opacity_multiplier_multiplier = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_MULTIPLIER,
        fog_screen_primary_color = DEFAULT_FOG_SCREEN_PRIMARY_COLOR,
        fog_screen_primary_color_weight = \
                DEFAULT_FOG_SCREEN_PRIMARY_COLOR_WEIGHT,
        fog_screen_secondary_color = DEFAULT_FOG_SCREEN_SECONDARY_COLOR,
        fog_screen_secondary_color_weight = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_WEIGHT,
        snow_density_multiplier = DEFAULT_SNOW_DENSITY_MULTIPLIER,
        windiness = DEFAULT_WINDINESS,
    },
    "2": {
        scene_path = "res://src/level/tiers/tier_2.tscn",
        camera_horizontally_locked = true,
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
        light_energy_multiplier = DEFAULT_LIGHT_ENERGY_MULTIPLIER,
        peep_hole_size_multiplier = DEFAULT_PEEP_HOLE_SIZE_MULTIPLIER,
        fog_screen_opacity = DEFAULT_FOG_SCREEN_OPACITY,
        fog_screen_opacity_weight = DEFAULT_FOG_SCREEN_OPACITY_WEIGHT,
        fog_screen_secondary_color_opacity_multiplier_multiplier = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_MULTIPLIER,
        fog_screen_primary_color = DEFAULT_FOG_SCREEN_PRIMARY_COLOR,
        fog_screen_primary_color_weight = \
                DEFAULT_FOG_SCREEN_PRIMARY_COLOR_WEIGHT,
        fog_screen_secondary_color = DEFAULT_FOG_SCREEN_SECONDARY_COLOR,
        fog_screen_secondary_color_weight = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_WEIGHT,
        snow_density_multiplier = DEFAULT_SNOW_DENSITY_MULTIPLIER,
        windiness = DEFAULT_WINDINESS,
    },
    "3": {
        scene_path = "res://src/level/tiers/tier_3.tscn",
        camera_horizontally_locked = true,
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
        light_energy_multiplier = DEFAULT_LIGHT_ENERGY_MULTIPLIER,
        peep_hole_size_multiplier = DEFAULT_PEEP_HOLE_SIZE_MULTIPLIER,
        fog_screen_opacity = DEFAULT_FOG_SCREEN_OPACITY,
        fog_screen_opacity_weight = DEFAULT_FOG_SCREEN_OPACITY_WEIGHT,
        fog_screen_secondary_color_opacity_multiplier_multiplier = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_MULTIPLIER,
        fog_screen_primary_color = DEFAULT_FOG_SCREEN_PRIMARY_COLOR,
        fog_screen_primary_color_weight = \
                DEFAULT_FOG_SCREEN_PRIMARY_COLOR_WEIGHT,
        fog_screen_secondary_color = DEFAULT_FOG_SCREEN_SECONDARY_COLOR,
        fog_screen_secondary_color_weight = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_WEIGHT,
        snow_density_multiplier = DEFAULT_SNOW_DENSITY_MULTIPLIER,
        windiness = DEFAULT_WINDINESS,
    },
    "4": {
        scene_path = "res://src/level/tiers/tier_4.tscn",
        camera_horizontally_locked = true,
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
        light_energy_multiplier = DEFAULT_LIGHT_ENERGY_MULTIPLIER,
        peep_hole_size_multiplier = DEFAULT_PEEP_HOLE_SIZE_MULTIPLIER,
        fog_screen_opacity = DEFAULT_FOG_SCREEN_OPACITY,
        fog_screen_opacity_weight = DEFAULT_FOG_SCREEN_OPACITY_WEIGHT,
        fog_screen_secondary_color_opacity_multiplier_multiplier = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_MULTIPLIER,
        fog_screen_primary_color = DEFAULT_FOG_SCREEN_PRIMARY_COLOR,
        fog_screen_primary_color_weight = \
                DEFAULT_FOG_SCREEN_PRIMARY_COLOR_WEIGHT,
        fog_screen_secondary_color = DEFAULT_FOG_SCREEN_SECONDARY_COLOR,
        fog_screen_secondary_color_weight = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_WEIGHT,
        snow_density_multiplier = DEFAULT_SNOW_DENSITY_MULTIPLIER,
        windiness = DEFAULT_WINDINESS,
    },
    "5": {
        scene_path = "res://src/level/tiers/tier_5.tscn",
        camera_horizontally_locked = true,
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
        light_energy_multiplier = DEFAULT_LIGHT_ENERGY_MULTIPLIER,
        peep_hole_size_multiplier = DEFAULT_PEEP_HOLE_SIZE_MULTIPLIER,
        fog_screen_opacity = DEFAULT_FOG_SCREEN_OPACITY,
        fog_screen_opacity_weight = DEFAULT_FOG_SCREEN_OPACITY_WEIGHT,
        fog_screen_secondary_color_opacity_multiplier_multiplier = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_MULTIPLIER,
        fog_screen_primary_color = DEFAULT_FOG_SCREEN_PRIMARY_COLOR,
        fog_screen_primary_color_weight = \
                DEFAULT_FOG_SCREEN_PRIMARY_COLOR_WEIGHT,
        fog_screen_secondary_color = DEFAULT_FOG_SCREEN_SECONDARY_COLOR,
        fog_screen_secondary_color_weight = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_WEIGHT,
        snow_density_multiplier = DEFAULT_SNOW_DENSITY_MULTIPLIER,
        windiness = DEFAULT_WINDINESS,
    },
    "6": {
        scene_path = "res://src/level/tiers/tier_6.tscn",
        camera_horizontally_locked = true,
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
        light_energy_multiplier = DEFAULT_LIGHT_ENERGY_MULTIPLIER,
        peep_hole_size_multiplier = DEFAULT_PEEP_HOLE_SIZE_MULTIPLIER,
        fog_screen_opacity = DEFAULT_FOG_SCREEN_OPACITY,
        fog_screen_opacity_weight = DEFAULT_FOG_SCREEN_OPACITY_WEIGHT,
        fog_screen_secondary_color_opacity_multiplier_multiplier = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_MULTIPLIER,
        fog_screen_primary_color = DEFAULT_FOG_SCREEN_PRIMARY_COLOR,
        fog_screen_primary_color_weight = \
                DEFAULT_FOG_SCREEN_PRIMARY_COLOR_WEIGHT,
        fog_screen_secondary_color = DEFAULT_FOG_SCREEN_SECONDARY_COLOR,
        fog_screen_secondary_color_weight = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_WEIGHT,
        snow_density_multiplier = DEFAULT_SNOW_DENSITY_MULTIPLIER,
        windiness = DEFAULT_WINDINESS,
    },
    "7": {
        scene_path = "res://src/level/tiers/tier_7.tscn",
        camera_horizontally_locked = true,
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
        light_energy_multiplier = DEFAULT_LIGHT_ENERGY_MULTIPLIER,
        peep_hole_size_multiplier = DEFAULT_PEEP_HOLE_SIZE_MULTIPLIER,
        fog_screen_opacity = DEFAULT_FOG_SCREEN_OPACITY,
        fog_screen_opacity_weight = DEFAULT_FOG_SCREEN_OPACITY_WEIGHT,
        fog_screen_secondary_color_opacity_multiplier_multiplier = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_MULTIPLIER,
        fog_screen_primary_color = DEFAULT_FOG_SCREEN_PRIMARY_COLOR,
        fog_screen_primary_color_weight = \
                DEFAULT_FOG_SCREEN_PRIMARY_COLOR_WEIGHT,
        fog_screen_secondary_color = DEFAULT_FOG_SCREEN_SECONDARY_COLOR,
        fog_screen_secondary_color_weight = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_WEIGHT,
        snow_density_multiplier = DEFAULT_SNOW_DENSITY_MULTIPLIER,
        windiness = DEFAULT_WINDINESS,
    },
}

const LEVELS := {
    "1": {
        tiers = ["1", "2", "3", "4", "5", "6", "7"],
        lives_count = DEFAULT_LIVES_COUNT,
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
        light_energy_multiplier = DEFAULT_LIGHT_ENERGY_MULTIPLIER,
        peep_hole_size_multiplier = DEFAULT_PEEP_HOLE_SIZE_MULTIPLIER,
        fog_screen_opacity = DEFAULT_FOG_SCREEN_OPACITY,
        fog_screen_opacity_weight = DEFAULT_FOG_SCREEN_OPACITY_WEIGHT,
        fog_screen_secondary_color_opacity_multiplier_multiplier = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_MULTIPLIER,
        fog_screen_primary_color = DEFAULT_FOG_SCREEN_PRIMARY_COLOR,
        fog_screen_primary_color_weight = \
                DEFAULT_FOG_SCREEN_PRIMARY_COLOR_WEIGHT,
        fog_screen_secondary_color = DEFAULT_FOG_SCREEN_SECONDARY_COLOR,
        fog_screen_secondary_color_weight = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_WEIGHT,
        snow_density_multiplier = DEFAULT_SNOW_DENSITY_MULTIPLIER,
        windiness = DEFAULT_WINDINESS,
    },
    "2": {
        tiers = ["6", "3"],
        lives_count = DEFAULT_LIVES_COUNT,
        zoom_multiplier = DEFAULT_ZOOM_MULTIPLIER,
        scroll_speed_multiplier = DEFAULT_SCROLL_SPEED_MULTIPLIER,
        scroll_speed_min = DEFAULT_SCROLL_SPEED_MIN,
        scroll_speed_max = DEFAULT_SCROLL_SPEED_MAX,
        light_energy_multiplier = DEFAULT_LIGHT_ENERGY_MULTIPLIER,
        peep_hole_size_multiplier = DEFAULT_PEEP_HOLE_SIZE_MULTIPLIER,
        fog_screen_opacity = DEFAULT_FOG_SCREEN_OPACITY,
        fog_screen_opacity_weight = DEFAULT_FOG_SCREEN_OPACITY_WEIGHT,
        fog_screen_secondary_color_opacity_multiplier_multiplier = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_MULTIPLIER,
        fog_screen_primary_color = DEFAULT_FOG_SCREEN_PRIMARY_COLOR,
        fog_screen_primary_color_weight = \
                DEFAULT_FOG_SCREEN_PRIMARY_COLOR_WEIGHT,
        fog_screen_secondary_color = DEFAULT_FOG_SCREEN_SECONDARY_COLOR,
        fog_screen_secondary_color_weight = \
                DEFAULT_FOG_SCREEN_SECONDARY_COLOR_WEIGHT,
        snow_density_multiplier = DEFAULT_SNOW_DENSITY_MULTIPLIER,
        windiness = DEFAULT_WINDINESS,
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
