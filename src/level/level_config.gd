extends Node

const TIER_EMPTY_OPEN_SCENE_PATH := \
        "res://src/level/tiers/tier_empty_open.tscn"
const TIER_EMPTY_WALLED_SCENE_PATH := \
        "res://src/level/tiers/tier_empty_walled.tscn"
const TIER_EMPTY_WALLED_LEFT_SCENE_PATH := \
        "res://src/level/tiers/tier_empty_walled_left.tscn"
const TIER_EMPTY_WALLED_RIGHT_SCENE_PATH := \
        "res://src/level/tiers/tier_empty_walled_right.tscn"

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

const FRAMERATE_MULTIPLIER_EASY_MIN := 0.8
const FRAMERATE_MULTIPLIER_EASY_MAX := 1.1
const FRAMERATE_MULTIPLIER_MODERATE_MIN := 1.25
const FRAMERATE_MULTIPLIER_MODERATE_MAX := 1.25
const FRAMERATE_MULTIPLIER_HARD_MIN := 1.25
const FRAMERATE_MULTIPLIER_HARD_MAX := 1.6

const _DEFAULT_TIER_VALUES := {
    id = "",
    number = -1,
    version = "",
    camera_horizontally_locked = true,
    zoom_multiplier = 1.0,
    scroll_speed_multiplier = 1.0,
    scroll_speed_min = 20.0,
    scroll_speed_max = 100.0,
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
    id = "",
    number = -1,
    name = "",
    version = "",
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
    # FIXME: Update these to be more reasonable defaults; but also add actual
    #        values in level configs;
    rank_thresholds = {
        Rank.GOLD: 10000,
        Rank.SILVER: 1000,
    },
    unlock_conditions = {
        bronze_levels = [],
        silver_levels = [],
        gold_levels = [],
        three_loop_levels = [],
    },
}

const _TIERS := {
    "0": {
        scene_path = "res://src/level/tiers/tier_base.tscn",
        scroll_speed_multiplier = 0.0,
        scroll_speed_min = 0.0,
        scroll_speed_max = 0.0,
        version = "0.1.0",
    },
    "1": {
        scene_path = "res://src/level/tiers/tier_1.tscn",
        # FIXME: --------------------------------- REMOVE
        peep_hole_size = {value = Vector2(200.0, 200.0), weight = 0.0},
        fog_screen_opacity = {value = 0.3, weight = 0.0},
        snow_density_multiplier = 4.0,
        windiness = {value = Vector2(2.0, -2.0), weight = 1.0},
        version = "0.1.0",
    },
    "2": {
        scene_path = "res://src/level/tiers/tier_2.tscn",
        version = "0.1.0",
    },
    "3": {
        scene_path = "res://src/level/tiers/tier_3.tscn",
        version = "0.1.0",
    },
    "4": {
        scene_path = "res://src/level/tiers/tier_4.tscn",
        version = "0.1.0",
    },
    "5": {
        scene_path = "res://src/level/tiers/tier_5.tscn",
        version = "0.1.0",
    },
    "6": {
        scene_path = "res://src/level/tiers/tier_6.tscn",
        version = "0.1.0",
    },
    "7": {
        scene_path = "res://src/level/tiers/tier_7.tscn",
        version = "0.1.0",
    },
}

const _LEVELS := {
    "1": {
        name = "foo",
        # FIXME: 
        tiers = ["1"],
#        tiers = ["1", "2", "3", "4", "5", "6", "7"],
        version = "0.1.0",
        unlock_conditions = {
        },
    },
    # FIXME: 
    "2": {
        name = "bar",
        tiers = ["1"],
        version = "0.1.0",
        unlock_conditions = {
            bronze_levels = ["1"],
        },
    },
    "3": {
        name = "bar",
        tiers = ["1"],
        version = "0.1.0",
        unlock_conditions = {
            bronze_levels = ["2"],
        },
    },
    "4": {
        name = "bar",
        tiers = ["1"],
        version = "0.1.0",
        unlock_conditions = {
            bronze_levels = ["3"],
        },
    },
    "5": {
        name = "bar",
        tiers = ["1"],
        version = "0.1.0",
        unlock_conditions = {
            bronze_levels = ["4"],
        },
    },
    "6": {
        name = "bar",
        tiers = ["1"],
        version = "0.1.0",
        unlock_conditions = {
            bronze_levels = ["5"],
        },
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
    assert(tier_config.has("version"))
    for key in _DEFAULT_TIER_VALUES.keys():
        if !tier_config.has(key):
            tier_config[key] = _DEFAULT_TIER_VALUES[key]
    tier_config["id"] = tier_id
    assert(tier_id == str(int(tier_id)))
    tier_config["number"] = int(tier_id)
    _inflated_tiers[tier_id] = tier_config
    return tier_config

static func get_level_config(level_id: String) -> Dictionary:
    if _inflated_levels.has(level_id):
        return _inflated_levels[level_id]
    
    assert(_LEVELS.has(level_id))
    var level_config: Dictionary = _LEVELS[level_id].duplicate()
    assert(level_config.has("name"))
    assert(level_config.has("tiers"))
    assert(level_config.has("version"))
    for key in _DEFAULT_LEVEL_VALUES.keys():
        if !level_config.has(key):
            var value = _DEFAULT_LEVEL_VALUES[key]
            if value == null:
                value = _DEFAULT_TIER_VALUES[key]
            level_config[key] = value
    level_config["id"] = level_id
    assert(level_id == str(int(level_id)))
    level_config["number"] = int(level_id)
    assert(level_config.rank_thresholds.has(Rank.GOLD))
    assert(level_config.rank_thresholds.has(Rank.SILVER))
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

static func get_tier_gap_scene_path( \
        from_openness_type: int,  \
        to_openness_type: int) -> String:
    return LevelConfig.OPENNESS_TO_TIER_GAP_SCENE_PATH \
            [from_openness_type][to_openness_type]

static func get_tier_version_string(tier_id: String) -> String:
    return tier_id + "v" + get_tier_config(tier_id).version

static func get_level_version_string(level_id: String) -> String:
    return level_id + "v" + get_level_config(level_id).version

static func get_level_tier_version_string( \
        level_id: String, \
        tier_id: String) -> String:
    return get_level_version_string(level_id) + ":" + \
            get_tier_version_string(tier_id)

static func get_is_tile_slippery( \
        tile_set: TileSet, \
        tile_id: int) -> bool:
    return SLIPPERY_TILES.has(tile_set.tile_get_name(tile_id))

static func get_friction_for_tile( \
        tile_set: TileSet, \
        tile_id: int) -> float:
    return SLIPPERY_FRICTION_MULTIPLIER if \
            get_is_tile_slippery(tile_set, tile_id) else \
            NON_SLIPPERY_FRICTION_MULTIPLIER

static func get_walk_sound_for_tile( \
        tile_set: TileSet, \
        tile_id: int) -> int:
    return Sound.WALK_ICE if \
            get_is_tile_slippery(tile_set, tile_id) else \
            Sound.WALK_SNOW

static func get_level_rank( \
        level_id: String, \
        score: int, \
        has_finished: bool) -> int:
    var config: Dictionary = get_level_config(level_id)
    if !has_finished:
        return Rank.UNRANKED
    elif score > config.rank_thresholds[Rank.GOLD]:
        return Rank.GOLD
    elif score > config.rank_thresholds[Rank.SILVER]:
        return Rank.SILVER
    else:
        return Rank.BRONZE

static func get_new_unlocked_levels() -> Array:
    var new_unlocked_levels := []
    for level_id in get_level_ids():
        if !SaveState.get_level_is_unlocked(level_id) and \
                _check_if_level_meets_unlock_conditions(level_id):
            new_unlocked_levels.push_back(level_id)
    return new_unlocked_levels

static func _check_if_level_meets_unlock_conditions(level_id: String) -> bool:
    var config := get_level_config(level_id)
    var is_unlocked := true
    for key in config.unlock_conditions:
        var other_level_ids: Array = config.unlock_conditions[key]
        match key:
            "bronze_levels":
                for other_level_id in other_level_ids:
                    if !SaveState.get_level_has_finished(other_level_id):
                        is_unlocked = false
                        break
            "silver_levels":
                for other_level_id in other_level_ids:
                    var other_config := get_level_config(other_level_id)
                    var rank_threshold: int = \
                            other_config.rank_thresholds[Rank.SILVER]
                    var other_high_score := SaveState \
                            .get_level_high_score(other_level_id)
                    if other_high_score < rank_threshold:
                        is_unlocked = false
                        break
            "gold_levels":
                for other_level_id in other_level_ids:
                    var other_config := get_level_config(other_level_id)
                    var rank_threshold: int = \
                            other_config.rank_thresholds[Rank.GOLD]
                    var other_high_score := SaveState \
                            .get_level_high_score(other_level_id)
                    if other_high_score < rank_threshold:
                        is_unlocked = false
                        break
            "three_loop_levels":
                for other_level_id in other_level_ids:
                    if !SaveState.get_level_has_three_looped(other_level_id):
                        is_unlocked = false
                        break
            _:
                Utils.error()
        if !is_unlocked:
            break
    return is_unlocked
