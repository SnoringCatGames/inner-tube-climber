extends Node

enum {
    BOUNCE,
    FALL,
    GAME_OVER_SUCCESS,
    GAME_OVER_FAILURE,
    JUMP,
    JUMP_INPUT,
    LAND,
    MENU_SELECT,
    MENU_SELECT_FANCY,
    MULTIPLIER_INCREASE,
    MULTIPLIER_DECREASE,
    SCORE_UPDATE,
    SIDEWAYS_INPUT,
    TIER_COMPLETE,
    TIER_COMPLETE_FINAL,
    WALK_SNOW,
    WALK_ICE,
    LOCK_LOW,
    LOCK_HIGH,
    CRACK_ICE,
    IGNITE,
    ICICLE_1,
    ICICLE_2,
    ICICLE_5,
    ACHIEVEMENT,
}

var MANIFEST := {
    BOUNCE: {
        stream = preload("res://assets/sounds/tuber_bounce.wav"),
        text = "BOUNCE",
        volume_db = -4.0,
    },
    FALL: {
        stream = preload("res://assets/sounds/fall.wav"),
        text = "FALL",
        volume_db = 18.0,
    },
    GAME_OVER_SUCCESS: {
        stream = preload("res://assets/sounds/cadence-success.wav"),
        text = "GAME_OVER_SUCCESS",
        volume_db = 8.0,
    },
    GAME_OVER_FAILURE: {
        stream = preload("res://assets/sounds/cadence-failure.wav"),
        text = "GAME_OVER_FAILURE",
        volume_db = 8.0,
    },
    JUMP: {
        stream = preload("res://assets/sounds/tuber_jump.wav"),
        text = "JUMP",
        volume_db = -6.0,
    },
    JUMP_INPUT: {
        stream = preload("res://assets/sounds/input_indicator.wav"),
        text = "JUMP_INPUT",
        volume_db = 3.0,
    },
    LAND: {
        stream = preload("res://assets/sounds/tuber_land.wav"),
        text = "LAND",
        volume_db = -0.0,
    },
    MENU_SELECT: {
        stream = preload("res://assets/sounds/menu_select.wav"),
        text = "MENU_SELECT",
        volume_db = -2.0,
    },
    MENU_SELECT_FANCY: {
        stream = preload("res://assets/sounds/menu_select_fancy.wav"),
        text = "MENU_SELECT_FANCY",
        volume_db = -6.0,
    },
    MULTIPLIER_INCREASE: {
        stream = preload("res://assets/sounds/multiplier_increase.wav"),
        text = "MULTIPLIER_INCREASE",
        volume_db = 8.0,
    },
    MULTIPLIER_DECREASE: {
        stream = preload("res://assets/sounds/multiplier_decrease.wav"),
        text = "MULTIPLIER_DECREASE",
        volume_db = 4.0,
    },
    SCORE_UPDATE: {
        stream = preload("res://assets/sounds/score.wav"),
        text = "SCORE_UPDATE",
        volume_db = -10.0,
    },
    SIDEWAYS_INPUT: {
        stream = preload("res://assets/sounds/input_indicator.wav"),
        text = "SIDEWAYS_INPUT",
        volume_db = 3.0,
    },
    TIER_COMPLETE: {
        stream = preload("res://assets/sounds/tier_complete.wav"),
        text = "TIER_COMPLETE",
        volume_db = 10.0,
    },
    TIER_COMPLETE_FINAL: {
        stream = preload("res://assets/sounds/tier_complete_final.wav"),
        text = "TIER_COMPLETE_FINAL",
        volume_db = 13.0,
    },
    WALK_SNOW: {
        stream = preload("res://assets/sounds/walk_snow.wav"),
        text = "WALK_SNOW",
        volume_db = 15.0,
    },
    WALK_ICE: {
        stream = preload("res://assets/sounds/walk_ice.wav"),
        text = "WALK_ICE",
        volume_db = 15.0,
    },
    LOCK_LOW: {
        stream = preload("res://assets/sounds/lock-low.wav"),
        text = "LOCK_LOW",
        volume_db = 0.0,
    },
    LOCK_HIGH: {
        stream = preload("res://assets/sounds/lock-high.wav"),
        text = "LOCK_HIGH",
        volume_db = 0.0,
    },
    CRACK_ICE: {
        stream = preload("res://assets/sounds/crack-ice.wav"),
        text = "CRACK_ICE",
        volume_db = -9.0,
    },
    IGNITE: {
        stream = preload("res://assets/sounds/ignite.wav"),
        text = "IGNITE",
        volume_db = 15.0,
    },
    ICICLE_1: {
        stream = preload("res://assets/sounds/icicle1.wav"),
        text = "ICICLE_1",
        volume_db = -3.0,
    },
    ICICLE_2: {
        stream = preload("res://assets/sounds/icicle2.wav"),
        text = "ICICLE_2",
        volume_db = -3.0,
    },
    ICICLE_5: {
        stream = preload("res://assets/sounds/icicle5.wav"),
        text = "ICICLE_5",
        volume_db = -3.0,
    },
    ACHIEVEMENT: {
        stream = preload("res://assets/sounds/achievement.wav"),
        text = "ACHIEVEMENT",
        volume_db = 12.0,
    },
}

const SOUND_BUS_INDEX := 1

func _init() -> void:
    AudioServer.add_bus(SOUND_BUS_INDEX)
    var bus_name := AudioServer.get_bus_name(SOUND_BUS_INDEX)
    
    for config in MANIFEST.values():
        var player := AudioStreamPlayer.new()
        player.stream = config.stream
        player.bus = bus_name
        add_child(player)
        config.player = player

func get_type_string(type: int) -> String:
    return MANIFEST[type].text
