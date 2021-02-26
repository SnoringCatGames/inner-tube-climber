extends Node

const TIERS_DIRECTORY := "res://src/level/tiers/"
const TIER_GAPS_DIRECTORY := "res://src/level/tier_gaps/"

const TIER_BASE_WALLED_SCENE_PATH := TIERS_DIRECTORY + "tier_base_walled.tscn"
const TIER_BASE_OPEN_SCENE_PATH := TIERS_DIRECTORY + "tier_base_open.tscn"

const TIER_EMPTY_OPEN_SCENE_PATH := \
        TIERS_DIRECTORY + "tier_empty_open.tscn"
const TIER_EMPTY_WALLED_SCENE_PATH := \
        TIERS_DIRECTORY + "tier_empty_walled.tscn"
const TIER_EMPTY_WALLED_LEFT_SCENE_PATH := \
        TIERS_DIRECTORY + "tier_empty_walled_left.tscn"
const TIER_EMPTY_WALLED_RIGHT_SCENE_PATH := \
        TIERS_DIRECTORY + "tier_empty_walled_right.tscn"

const TIER_GAP_OPEN_TO_OPEN_SCENE_PATH := \
        TIER_GAPS_DIRECTORY + "tier_gap_open_to_open.tscn"
const TIER_GAP_OPEN_TO_WALLED_SCENE_PATH := \
        TIER_GAPS_DIRECTORY + "tier_gap_open_to_walled.tscn"
const TIER_GAP_OPEN_TO_WALLED_LEFT_SCENE_PATH := \
        TIER_GAPS_DIRECTORY + "tier_gap_open_to_walled_left.tscn"
const TIER_GAP_OPEN_TO_WALLED_RIGHT_SCENE_PATH := \
        TIER_GAPS_DIRECTORY + "tier_gap_open_to_walled_right.tscn"

const TIER_GAP_WALLED_TO_OPEN_SCENE_PATH := \
        TIER_GAPS_DIRECTORY + "tier_gap_walled_to_open.tscn"
const TIER_GAP_WALLED_TO_WALLED_SCENE_PATH := \
        TIER_GAPS_DIRECTORY + "tier_gap_walled_to_walled.tscn"
const TIER_GAP_WALLED_TO_WALLED_LEFT_SCENE_PATH := \
        TIER_GAPS_DIRECTORY + "tier_gap_walled_to_walled_left.tscn"
const TIER_GAP_WALLED_TO_WALLED_RIGHT_SCENE_PATH := \
        TIER_GAPS_DIRECTORY + "tier_gap_walled_to_walled_right.tscn"

const TIER_GAP_WALLED_LEFT_TO_OPEN_SCENE_PATH := \
        TIER_GAPS_DIRECTORY + "tier_gap_walled_left_to_open.tscn"
const TIER_GAP_WALLED_LEFT_TO_WALLED_SCENE_PATH := \
        TIER_GAPS_DIRECTORY + "tier_gap_walled_left_to_walled.tscn"
const TIER_GAP_WALLED_LEFT_TO_WALLED_LEFT_SCENE_PATH := \
        TIER_GAPS_DIRECTORY + "tier_gap_walled_left_to_walled_left.tscn"
const TIER_GAP_WALLED_LEFT_TO_WALLED_RIGHT_SCENE_PATH := \
        TIER_GAPS_DIRECTORY + "tier_gap_walled_left_to_walled_right.tscn"

const TIER_GAP_WALLED_RIGHT_TO_OPEN_SCENE_PATH := \
        TIER_GAPS_DIRECTORY + "tier_gap_walled_right_to_open.tscn"
const TIER_GAP_WALLED_RIGHT_TO_WALLED_SCENE_PATH := \
        TIER_GAPS_DIRECTORY + "tier_gap_walled_right_to_walled.tscn"
const TIER_GAP_WALLED_RIGHT_TO_WALLED_LEFT_SCENE_PATH := \
        TIER_GAPS_DIRECTORY + "tier_gap_walled_right_to_walled_left.tscn"
const TIER_GAP_WALLED_RIGHT_TO_WALLED_RIGHT_SCENE_PATH := \
        TIER_GAPS_DIRECTORY + "tier_gap_walled_right_to_walled_right.tscn"

# Dictionary<OpennessType, Dictionary<OpennessType, String>>
const OPENNESS_TO_TIER_GAP_SCENE_PATH := {
    OpennessType.OPEN: {
        OpennessType.OPEN: \
                TIER_GAP_OPEN_TO_OPEN_SCENE_PATH,
        OpennessType.WALLED: \
                TIER_GAP_OPEN_TO_WALLED_SCENE_PATH,
        OpennessType.WALLED_LEFT: \
                TIER_GAP_OPEN_TO_WALLED_LEFT_SCENE_PATH,
        OpennessType.WALLED_RIGHT: \
                TIER_GAP_OPEN_TO_WALLED_RIGHT_SCENE_PATH,
    },
    OpennessType.WALLED: {
        OpennessType.OPEN: \
                TIER_GAP_WALLED_TO_OPEN_SCENE_PATH,
        OpennessType.WALLED: \
                TIER_GAP_WALLED_TO_WALLED_SCENE_PATH,
        OpennessType.WALLED_LEFT: \
                TIER_GAP_WALLED_TO_WALLED_LEFT_SCENE_PATH,
        OpennessType.WALLED_RIGHT: \
                TIER_GAP_WALLED_TO_WALLED_RIGHT_SCENE_PATH,
    },
    OpennessType.WALLED_LEFT: {
        OpennessType.OPEN: \
                TIER_GAP_WALLED_LEFT_TO_OPEN_SCENE_PATH,
        OpennessType.WALLED: \
                TIER_GAP_WALLED_LEFT_TO_WALLED_SCENE_PATH,
        OpennessType.WALLED_LEFT: \
                TIER_GAP_WALLED_LEFT_TO_WALLED_LEFT_SCENE_PATH,
        OpennessType.WALLED_RIGHT: \
                TIER_GAP_WALLED_LEFT_TO_WALLED_RIGHT_SCENE_PATH,
    },
    OpennessType.WALLED_RIGHT: {
        OpennessType.OPEN: \
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

const _DEFAULT_MUSIC_SEQUENCE := [
    Music.STUCK_IN_A_CREVASSE,
    Music.NO_ESCAPE_FROM_THE_LOOP,
    Music.RISING_THROUGH_RARIFIED_AIR,
    Music.OUT_FOR_A_LOOP_RIDE,
    Music.PUMP_UP_THAT_TUBE,
]

const _DEFAULT_TIER_VALUES := {
    id = "",
    number = -1,
    version = "",
    scene_path = "",
    openness_type = OpennessType.UNKNOWN,
    is_base_tier = false,
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
    music_sequence = _DEFAULT_MUSIC_SEQUENCE,
    zoom_multiplier = _DEFAULT_TIER_VALUES.zoom_multiplier,
    scroll_speed_multiplier = _DEFAULT_TIER_VALUES.scroll_speed_multiplier,
    scroll_speed_min = _DEFAULT_TIER_VALUES.scroll_speed_min,
    scroll_speed_max = _DEFAULT_TIER_VALUES.scroll_speed_max,
    light_energy = _DEFAULT_TIER_VALUES.light_energy,
    peep_hole_size = _DEFAULT_TIER_VALUES.peep_hole_size,
    fog_screen_opacity = _DEFAULT_TIER_VALUES.fog_screen_opacity,
    fog_screen_secondary_color_opacity_multiplier = \
            _DEFAULT_TIER_VALUES.fog_screen_secondary_color_opacity_multiplier,
    fog_screen_primary_color = _DEFAULT_TIER_VALUES.fog_screen_primary_color,
    fog_screen_secondary_color = \
            _DEFAULT_TIER_VALUES.fog_screen_secondary_color,
    snow_density_multiplier = _DEFAULT_TIER_VALUES.snow_density_multiplier,
    windiness = _DEFAULT_TIER_VALUES.windiness,
    # FIXME: Update these to be more reasonable defaults; but also add actual
    #        values in level configs;
    rank_thresholds = {
        Rank.GOLD: 4000,
        Rank.SILVER: 1000,
    },
    unlock_conditions = {
        bronze_levels = [],
        silver_levels = [],
        gold_levels = [],
        three_loop_levels = [],
    },
}

var _TIERS := {
    # Special tiers.
    "-2": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
    },
    "-1": {
        version = "0.1.0",
        openness_type = OpennessType.OPEN,
    },
    "0": {
        version = "0.1.0",
        scene_path = TIER_BASE_WALLED_SCENE_PATH,
        openness_type = OpennessType.WALLED,
        is_base_tier = true,
        scroll_speed_multiplier = 0.0,
        scroll_speed_min = 0.0,
        scroll_speed_max = 0.0,
    },
    
    # Normal tiers.
    "1": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
    },
    "2": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
    },
    "3": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
    },
    "4": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
    },
    "5": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
    },
    "6": {
        version = "0.1.0",
        openness_type = OpennessType.OPEN,
    },
    "7": {
        version = "0.1.0",
        openness_type = OpennessType.OPEN,
    },
    "8": {
        version = "0.1.0",
        openness_type = OpennessType.OPEN,
        camera_horizontally_locked = false,
        scroll_speed_max = 32.0,
    },
    "9": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
    },
    "10": {
        version = "0.1.0",
        openness_type = OpennessType.OPEN,
        camera_horizontally_locked = false,
        scroll_speed_max = 32.0,
        peep_hole_size = {value = Vector2(300.0, 300.0), weight = 1.0},
        fog_screen_opacity = {value = 0.95, weight = 1.0},
        fog_screen_secondary_color_opacity_multiplier = \
                {value = 0.9, weight = 1.0},
        fog_screen_primary_color = {value = Color("#000000"), weight = 1.0},
        fog_screen_secondary_color = {value = Color("#1c2226"), weight = 1.0},
        light_energy = {value = 0.9, weight = 1.0},
        snow_density_multiplier = 8.0,
        windiness = {value = Vector2(3.0, -3.0), weight = 1.0},
    },
    "11": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED_LEFT,
        snow_density_multiplier = 3.0,
        windiness = {value = Vector2(-3.0, -1.0), weight = 1.0},
    },
    "12": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED_LEFT,
        snow_density_multiplier = 3.0,
        windiness = {value = Vector2(0.0, 5.0), weight = 1.0},
    },
    "13": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED_LEFT,
        snow_density_multiplier = 3.0,
        windiness = {value = Vector2(0.0, -5.1), weight = 1.0},
    },
    "14": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
    },
    "15": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
    },
    "16": {
        version = "0.1.0",
        openness_type = OpennessType.OPEN,
        camera_horizontally_locked = false,
    },
    "17": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
    },
    "18": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
    },
    "19": {
        version = "0.1.0",
        openness_type = OpennessType.OPEN,
    },
    "20": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
    },
    "21": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
    },
    "22": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
    },
    "23": {
        version = "0.1.0",
        openness_type = OpennessType.OPEN,
        camera_horizontally_locked = false,
        scroll_speed_max = 32.0,
        peep_hole_size = {value = Vector2(200.0, 200.0), weight = 1.0},
        fog_screen_opacity = {value = 0.99, weight = 1.0},
        fog_screen_secondary_color_opacity_multiplier = \
                {value = 0.1, weight = 1.0},
        fog_screen_primary_color = {value = Constants.WALL_COLOR, weight = 1.0},
        fog_screen_secondary_color = {value = Color("#ffffff"), weight = 1.0},
        light_energy = {value = 0.9, weight = 1.0},
        snow_density_multiplier = 2.0,
    },
    "24": {
        version = "0.1.0",
        openness_type = OpennessType.OPEN,
        camera_horizontally_locked = false,
        scroll_speed_max = 32.0,
        peep_hole_size = {value = Vector2(300.0, 300.0), weight = 1.0},
        fog_screen_opacity = {value = 0.99, weight = 1.0},
        fog_screen_secondary_color_opacity_multiplier = \
                {value = 0.1, weight = 1.0},
        fog_screen_primary_color = {value = Constants.WALL_COLOR, weight = 1.0},
        fog_screen_secondary_color = {value = Color("#ffffff"), weight = 1.0},
        light_energy = {value = 0.99, weight = 1.0},
        snow_density_multiplier = 4.0,
        windiness = {value = Vector2(0.0, -2.0), weight = 1.0},
    },
    "25": {
        version = "0.1.0",
        openness_type = OpennessType.OPEN,
        camera_horizontally_locked = false,
        scroll_speed_max = 32.0,
        peep_hole_size = {value = Vector2(400.0, 400.0), weight = 1.0},
        fog_screen_opacity = {value = 0.95, weight = 1.0},
        fog_screen_secondary_color_opacity_multiplier = \
                {value = 0.96, weight = 1.0},
        fog_screen_primary_color = {value = Color("#ffffff"), weight = 1.0},
        fog_screen_secondary_color = {value = Color("#d3e2ed"), weight = 1.0},
        light_energy = {value = 0.99, weight = 1.0},
        snow_density_multiplier = 8.0,
    },
    "26": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
        zoom_multiplier = 1.0,
        snow_density_multiplier = 20.0,
        fog_screen_opacity = {value = 0.99, weight = 1.0},
        fog_screen_secondary_color_opacity_multiplier = \
                {value = 0.1, weight = 1.0},
        fog_screen_primary_color = {value = Color("#ffffff"), weight = 1.0},
        fog_screen_secondary_color = {value = Color("#d3e2ed"), weight = 1.0},
    },
    "27": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
        camera_horizontally_locked = false,
        zoom_multiplier = 0.66667,
        snow_density_multiplier = 16.0,
        fog_screen_opacity = {value = 0.99, weight = 1.0},
        fog_screen_secondary_color_opacity_multiplier = \
                {value = 0.5, weight = 1.0},
        fog_screen_primary_color = {value = Color("#ffffff"), weight = 1.0},
        fog_screen_secondary_color = \
                {value = Constants.WALL_COLOR, weight = 1.0},
        windiness = {value = Vector2(3.0, 3.0), weight = 1.0},
    },
    "28": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
        camera_horizontally_locked = false,
        zoom_multiplier = 0.5,
        snow_density_multiplier = 16.0,
        fog_screen_opacity = {value = 0.99, weight = 1.0},
        fog_screen_secondary_color_opacity_multiplier = \
                {value = 0.5, weight = 1.0},
        fog_screen_primary_color = {value = Color("#ffffff"), weight = 1.0},
        fog_screen_secondary_color = \
                {value = Constants.BACKGROUND_DARKEST_COLOR, weight = 1.0},
        windiness = {value = Vector2(-3.0, -3.0), weight = 1.0},
    },
    "29": {
        version = "0.1.0",
        openness_type = OpennessType.WALLED,
    },
}

var _LEVELS := {
    "1": {
        name = "Jump",
        tiers = ["1", "21", "20"],
        music_sequence = [
            Music.STUCK_IN_A_CREVASSE,
            Music.NO_ESCAPE_FROM_THE_LOOP,
            Music.OUT_FOR_A_LOOP_RIDE,
        ],
        version = "0.1.0",
        unlock_conditions = {
        },
    },
    "2": {
        name = "Climb",
        tiers = ["3", "2", "22"],
        music_sequence = [
            Music.OUT_FOR_A_LOOP_RIDE,
            Music.STUCK_IN_A_CREVASSE,
            Music.PUMP_UP_THAT_TUBE,
        ],
        version = "0.1.0",
        unlock_conditions = {
            bronze_levels = ["1"],
        },
    },
    "3": {
        name = "Slip",
        tiers = ["9", "15", "4"],
        music_sequence = [
            Music.STUCK_IN_A_CREVASSE,
            Music.RISING_THROUGH_RARIFIED_AIR,
            Music.PUMP_UP_THAT_TUBE,
        ],
        version = "0.1.0",
        unlock_conditions = {
            bronze_levels = ["2"],
        },
    },
    "4": {
        name = "* Minor",
        levels = ["1", "2", "3"],
        version = "0.1.0",
        unlock_conditions = {
            silver_levels = ["1", "2", "3"],
        },
    },
    "5": {
        name = "Bounce",
        tiers = ["5", "14", "18"],
        music_sequence = [
            Music.NO_ESCAPE_FROM_THE_LOOP,
            Music.OUT_FOR_A_LOOP_RIDE,
            Music.PUMP_UP_THAT_TUBE,
        ],
        version = "0.1.0",
        unlock_conditions = {
            bronze_levels = ["3"],
        },
    },
    "6": {
        name = "Open",
        tiers = ["6", "7", "19"],
        music_sequence = [
            Music.STUCK_IN_A_CREVASSE,
            Music.RISING_THROUGH_RARIFIED_AIR,
            Music.NO_ESCAPE_FROM_THE_LOOP,
        ],
        version = "0.1.0",
        unlock_conditions = {
            bronze_levels = ["5"],
        },
    },
    "7": {
        name = "Switchback",
        tiers = ["8", "16", "17"],
        music_sequence = [
            Music.OUT_FOR_A_LOOP_RIDE,
            Music.PUMP_UP_THAT_TUBE,
            Music.RISING_THROUGH_RARIFIED_AIR,
        ],
        version = "0.1.0",
        unlock_conditions = {
            bronze_levels = ["6"],
        },
    },
    "8": {
        name = "* Moderate",
        levels = ["5", "6", "7"],
        version = "0.1.0",
        unlock_conditions = {
            silver_levels = ["5", "6", "7"],
        },
    },
    "9": {
        name = "Flurry",
        tiers = ["11", "12", "13"],
        music_sequence = [
            Music.NO_ESCAPE_FROM_THE_LOOP,
            Music.OUT_FOR_A_LOOP_RIDE,
            Music.RISING_THROUGH_RARIFIED_AIR,
        ],
        version = "0.1.0",
        lives_count = 4,
        unlock_conditions = {
            bronze_levels = ["7"],
        },
    },
    "10": {
        name = "Shroud",
        tiers = ["23", "24", "10"],
        music_sequence = [
            Music.STUCK_IN_A_CREVASSE,
            Music.RISING_THROUGH_RARIFIED_AIR,
            Music.NO_ESCAPE_FROM_THE_LOOP,
        ],
        version = "0.1.0",
        lives_count = 4,
        unlock_conditions = {
            bronze_levels = ["9"],
        },
    },
    "11": {
        name = "Scale",
        tiers = ["26", "27", "28"],
        music_sequence = [
            Music.NO_ESCAPE_FROM_THE_LOOP,
            Music.RISING_THROUGH_RARIFIED_AIR,
            Music.PUMP_UP_THAT_TUBE,
        ],
        version = "0.1.0",
        lives_count = 5,
        unlock_conditions = {
            bronze_levels = ["10"],
        },
    },
    "12": {
        name = "* Major",
        levels = ["9", "10", "11"],
        version = "0.1.0",
        unlock_conditions = {
            silver_levels = ["9", "10", "11"],
        },
    },
    "13": {
        name = "Scatter",
        tiers = ["25", "29"],
        music_sequence = [
            Music.PUMP_UP_THAT_TUBE,
            Music.OUT_FOR_A_LOOP_RIDE,
        ],
        version = "0.1.0",
        unlock_conditions = {
            bronze_levels = ["11"],
        },
    },
    "14": {
        name = "* Ultimate",
        levels = [
            "1", "2", "3",
            "5", "6", "7",
            "9", "10", "11",
            "13",
        ],
        version = "0.1.0",
        unlock_conditions = {
            bronze_levels = ["4", "8", "12", "13"],
        },
    },
}

var _inflated_tiers := {}
var _inflated_levels := {}

var EMPTY_WALLED_TIER: Dictionary = get_tier_config("-2")
var EMPTY_OPEN_TIER: Dictionary = get_tier_config("-1")
var BASE_TIER: Dictionary = get_tier_config("0")

func _init() -> void:
    SaveState.set_level_is_unlocked("1", true)
    
    if Constants.DEBUG or Constants.PLAYTEST:
        _create_a_test_level_for_each_tier()
    
    if Constants.DEBUG:
        _add_extra_lives_to_each_level()

func _create_a_test_level_for_each_tier() -> void:
    var max_level_number := -INF
    for level_id in _LEVELS:
        max_level_number = max(int(level_id), max_level_number)
    
    for tier_id in _TIERS:
        if int(tier_id) <= 0:
            continue
        max_level_number += 1
        var level_id := str(max_level_number)
        var music: int = _DEFAULT_MUSIC_SEQUENCE[ \
                int(randf() * _DEFAULT_MUSIC_SEQUENCE.size())]
        _LEVELS[level_id] = {
            name = "TEST: Tier " + tier_id,
            tiers = [tier_id],
            music_sequence = [music],
            version = "0.1.0",
            unlock_conditions = {
            },
        }
        SaveState.set_level_is_unlocked(level_id, true)

func _add_extra_lives_to_each_level() -> void:
    for level_id in _LEVELS:
        if !_LEVELS[level_id].has("lives_count"):
            _LEVELS[level_id]["lives_count"] = \
                    _DEFAULT_LEVEL_VALUES["lives_count"]
        _LEVELS[level_id]["lives_count"] = \
                _LEVELS[level_id]["lives_count"] + 10

func get_tier_config(tier_id: String) -> Dictionary:
    if _inflated_tiers.has(tier_id):
        return _inflated_tiers[tier_id]
    
    assert(_TIERS.has(tier_id))
    var tier_config: Dictionary = _TIERS[tier_id].duplicate()
    assert(tier_config.has("version"))
    assert(tier_config.has("openness_type"))
    for key in _DEFAULT_TIER_VALUES.keys():
        if !tier_config.has(key):
            tier_config[key] = _DEFAULT_TIER_VALUES[key]
    tier_config["id"] = tier_id
    assert(tier_id == str(int(tier_id)))
    tier_config["number"] = int(tier_id)
    if tier_config.scene_path == "":
        tier_config.scene_path = TIERS_DIRECTORY + "tier_" + tier_id + ".tscn"
    _inflated_tiers[tier_id] = tier_config
    return tier_config

func get_level_config(level_id: String) -> Dictionary:
    if _inflated_levels.has(level_id):
        return _inflated_levels[level_id]
    
    assert(_LEVELS.has(level_id))
    var level_config: Dictionary = _LEVELS[level_id].duplicate()
    assert(level_config.has("name"))
    assert(level_config.has("tiers") or level_config.has("levels"))
    assert(level_config.has("version"))
    
    for key in _DEFAULT_LEVEL_VALUES.keys():
        if !level_config.has(key):
            var value = _DEFAULT_LEVEL_VALUES[key]
            if value == null:
                value = _DEFAULT_TIER_VALUES[key]
            level_config[key] = value
    
    if level_config.has("levels"):
        assert(!level_config.has("tiers"))
        var tiers := []
        var music_sequence := []
        for other_level_id in level_config["levels"]:
            var other_level_config := get_level_config(other_level_id)
            Utils.concat(tiers, other_level_config["tiers"])
            Utils.concat(music_sequence, other_level_config["music_sequence"])
        level_config["tiers"] = tiers
        level_config["music_sequence"] = music_sequence
    
    level_config["id"] = level_id
    assert(level_id == str(int(level_id)))
    level_config["number"] = int(level_id)
    assert(level_config.rank_thresholds.has(Rank.GOLD))
    assert(level_config.rank_thresholds.has(Rank.SILVER))
    
    _inflated_levels[level_id] = level_config
    return level_config

func get_value( \
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

func get_level_ids() -> Array:
    return _LEVELS.keys()

func get_tier_gap_scene_path( \
        from_openness_type: int,  \
        to_openness_type: int) -> String:
    return LevelConfig.OPENNESS_TO_TIER_GAP_SCENE_PATH \
            [from_openness_type][to_openness_type]

func get_tier_version_string(tier_id: String) -> String:
    return tier_id + "v" + get_tier_config(tier_id).version

func get_level_version_string(level_id: String) -> String:
    return level_id + "v" + get_level_config(level_id).version

func get_level_tier_version_string( \
        level_id: String, \
        tier_id: String) -> String:
    return get_level_version_string(level_id) + ":" + \
            get_tier_version_string(tier_id)

func get_is_tile_slippery( \
        tile_set: TileSet, \
        tile_id: int) -> bool:
    return SLIPPERY_TILES.has(tile_set.tile_get_name(tile_id))

func get_friction_for_tile( \
        tile_set: TileSet, \
        tile_id: int) -> float:
    return SLIPPERY_FRICTION_MULTIPLIER if \
            get_is_tile_slippery(tile_set, tile_id) else \
            NON_SLIPPERY_FRICTION_MULTIPLIER

func get_walk_sound_for_tile( \
        tile_set: TileSet, \
        tile_id: int) -> int:
    return Sound.WALK_ICE if \
            get_is_tile_slippery(tile_set, tile_id) else \
            Sound.WALK_SNOW

func get_level_rank( \
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

func get_old_unlocked_levels() -> Array:
    var old_unlocked_levels := []
    for level_id in get_level_ids():
        if SaveState.get_level_is_unlocked(level_id):
            old_unlocked_levels.push_back(level_id)
    return old_unlocked_levels

func get_new_unlocked_levels() -> Array:
    var new_unlocked_levels := []
    for level_id in get_level_ids():
        if !SaveState.get_level_is_unlocked(level_id) and \
                _check_if_level_meets_unlock_conditions(level_id):
            new_unlocked_levels.push_back(level_id)
    return new_unlocked_levels

func _check_if_level_meets_unlock_conditions(level_id: String) -> bool:
    return get_unlock_hint(level_id) == ""

func get_unlock_hint(level_id: String) -> String:
    var config := get_level_config(level_id)
    var hint := ""
    for key in config.unlock_conditions:
        var other_level_ids: Array = config.unlock_conditions[key]
        if !hint.empty() and \
                !other_level_ids.empty():
            hint += ". "
        match key:
            "bronze_levels":
                var bronze_hint := ""
                for other_level_id in other_level_ids:
                    if !has_level_earned_rank(other_level_id, Rank.BRONZE):
                        bronze_hint += " " + other_level_id
                if bronze_hint != "":
                    hint += "Finish level" + bronze_hint
            "silver_levels":
                var silver_hint := ""
                for other_level_id in other_level_ids:
                    if !has_level_earned_rank(other_level_id, Rank.SILVER):
                        silver_hint += " " + other_level_id
                if silver_hint != "":
                    hint += "Get silver on level" + silver_hint
            "gold_levels":
                var gold_hint := ""
                for other_level_id in other_level_ids:
                    if !has_level_earned_rank(other_level_id, Rank.GOLD):
                        gold_hint += " " + other_level_id
                if gold_hint != "":
                    hint += "Get gold on level" + gold_hint
            "three_loop_levels":
                var three_loop_hint := ""
                for other_level_id in other_level_ids:
                    if !SaveState.get_level_has_three_looped(other_level_id):
                        three_loop_hint += " " + other_level_id
                if three_loop_hint != "":
                    hint += "Three-loop level" + three_loop_hint
            _:
                Utils.error()
    if !hint.empty():
        hint += "."
    return hint

func has_level_earned_rank( \
        level_id: String, \
        rank: int) -> bool:
    var config := get_level_config(level_id)
    if rank == Rank.UNRANKED:
        return true
    elif rank == Rank.BRONZE:
        return SaveState.get_level_has_finished(level_id)
    else:
        var rank_threshold: int = config.rank_thresholds[rank]
        var high_score := SaveState.get_level_high_score(level_id)
        return high_score >= rank_threshold

func get_next_level_to_unlock() -> String:
    var locked_level_numbers := []
    for level_id in get_level_ids():
        if !SaveState.get_level_is_unlocked(level_id):
            var config := get_level_config(level_id)
            locked_level_numbers.push_back(config.number)
    locked_level_numbers.sort()
    
    if locked_level_numbers.empty():
        return ""
    else:
        return str(locked_level_numbers.front())

func get_score_for_next_rank_str( \
        level_id: String, \
        current_rank: int) -> String:
    var config := get_level_config(level_id)
    match current_rank:
        Rank.BRONZE:
            return str(config.rank_thresholds[Rank.SILVER])
        Rank.SILVER:
            return str(config.rank_thresholds[Rank.GOLD])
        Rank.GOLD:
            return "-"
        Rank.UNRANKED:
            return "(finish level)"
        _:
            Utils.error()
            return ""

func get_suggested_next_level() -> String:
    var next_level_number = INF
    for rank in [Rank.BRONZE, Rank.SILVER, Rank.GOLD]:
        for level_id in get_level_ids():
            if !has_level_earned_rank(level_id, rank) and \
                    int(level_id) < next_level_number and \
                    SaveState.get_level_is_unlocked(level_id):
                next_level_number = int(level_id)
        
        if next_level_number != INF:
            return str(next_level_number)
    
    for level_id in get_level_ids():
        if !SaveState.get_level_has_three_looped(level_id) and \
                int(level_id) < next_level_number and \
                SaveState.get_level_is_unlocked(level_id):
            next_level_number = int(level_id)
    
    if next_level_number != INF:
        return str(next_level_number)
    
    return "1"
