extends Node

var MUSIC_STREAM_0: AudioStream = \
        load("res://assets/music/stuck_in_a_crevasse.wav") if \
        Utils.get_is_ios_device() else \
        load("res://assets/music/stuck_in_a_crevasse.ogg")
var MUSIC_STREAM_1: AudioStream = \
        load("res://assets/music/no_escape_from_the_loop.wav") if \
        Utils.get_is_ios_device() else \
        load("res://assets/music/no_escape_from_the_loop.ogg")
var MUSIC_STREAM_2: AudioStream = \
        load("res://assets/music/rising-through-rarified-air.wav") if \
        Utils.get_is_ios_device() else \
        load("res://assets/music/rising-through-rarified-air.ogg")
var MUSIC_STREAM_3: AudioStream = \
        load("res://assets/music/out_for_a_loop_ride.wav") if \
        Utils.get_is_ios_device() else \
        load("res://assets/music/out_for_a_loop_ride.ogg")
var MUSIC_STREAM_4: AudioStream = \
        load("res://assets/music/pump-up-that-tube.wav") if \
        Utils.get_is_ios_device() else \
        load("res://assets/music/pump-up-that-tube.ogg")

enum {
    STUCK_IN_A_CREVASSE,
    NO_ESCAPE_FROM_THE_LOOP,
    RISING_THROUGH_RARIFIED_AIR,
    OUT_FOR_A_LOOP_RIDE,
    PUMP_UP_THAT_TUBE,
}

var MANIFEST := {
    STUCK_IN_A_CREVASSE: {
        stream = \
                load("res://assets/music/stuck_in_a_crevasse.wav") if \
                Utils.get_is_ios_device() else \
                load("res://assets/music/stuck_in_a_crevasse.ogg"),
        text = "STUCK_IN_A_CREVASSE",
        volume_db = 6.0,
    },
    NO_ESCAPE_FROM_THE_LOOP: {
        stream = \
                load("res://assets/music/no_escape_from_the_loop.wav") if \
                Utils.get_is_ios_device() else \
                load("res://assets/music/no_escape_from_the_loop.ogg"),
        text = "NO_ESCAPE_FROM_THE_LOOP",
        volume_db = 6.0,
    },
    RISING_THROUGH_RARIFIED_AIR: {
        stream = \
                load("res://assets/music/rising-through-rarified-air.wav") if \
                Utils.get_is_ios_device() else \
                load("res://assets/music/rising-through-rarified-air.ogg"),
        text = "RISING_THROUGH_RARIFIED_AIR",
        volume_db = 8.0,
    },
    OUT_FOR_A_LOOP_RIDE: {
        stream = \
                load("res://assets/music/out_for_a_loop_ride.wav") if \
                Utils.get_is_ios_device() else \
                load("res://assets/music/out_for_a_loop_ride.ogg"),
        text = "OUT_FOR_A_LOOP_RIDE",
        volume_db = 7.0,
    },
    PUMP_UP_THAT_TUBE: {
        stream = \
                load("res://assets/music/pump-up-that-tube.wav") if \
                Utils.get_is_ios_device() else \
                load("res://assets/music/pump-up-that-tube.ogg"),
        text = "PUMP_UP_THAT_TUBE",
        volume_db = 4.0,
    },
}

const MUSIC_BUS_INDEX := 2

func _init() -> void:
    AudioServer.add_bus(MUSIC_BUS_INDEX)
    var bus_name := AudioServer.get_bus_name(MUSIC_BUS_INDEX)
    
    for config in MANIFEST.values():
        var player := AudioStreamPlayer.new()
        player.stream = config.stream
        player.bus = bus_name
        add_child(player)
        config.player = player

func get_player(type: int) -> AudioStreamPlayer:
    return MANIFEST[type].player

func get_type_string(type: int) -> String:
    return MANIFEST[type].text

func get_volume_for_player(player: AudioStreamPlayer) -> float:
    for config in Music.MANIFEST.values():
        if config.player == player:
            return config.volume_db
    Utils.error()
    return -80.0
