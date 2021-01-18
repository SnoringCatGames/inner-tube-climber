extends Node

enum {
    BOUNCE,
    FALL,
    GAME_OVER,
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
}

var MANIFEST := {
    BOUNCE: {
        stream = preload("res://assets/sounds/tuber_bounce.wav"),
        text = "BOUNCE",
        volume_db = -2.0,
    },
    FALL: {
        stream = preload("res://assets/sounds/fall.wav"),
        text = "FALL",
        volume_db = 16.0,
    },
    GAME_OVER: {
        stream = preload("res://assets/sounds/yeti_yell.wav"),
        text = "GAME_OVER",
        volume_db = -6.0,
    },
    JUMP: {
        stream = preload("res://assets/sounds/tuber_jump.wav"),
        text = "JUMP",
        volume_db = -6.0,
    },
    JUMP_INPUT: {
        stream = preload("res://assets/sounds/blip.wav"),
        text = "JUMP_INPUT",
        volume_db = -8.0,
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
        stream = preload("res://assets/sounds/blip.wav"),
        text = "SIDEWAYS_INPUT",
        volume_db = -8.0,
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