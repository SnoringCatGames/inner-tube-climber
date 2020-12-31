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
        load("res://assets/music/out_for_a_loop_ride.wav") if \
        Utils.get_is_ios_device() else \
        load("res://assets/music/out_for_a_loop_ride.ogg")

enum {
    NO_ESCAPE_FROM_THE_LOOP,
    OUT_FOR_A_LOOP_RIDE,
    STUCK_IN_A_CREVASSE,
}

var MANIFEST := {
    NO_ESCAPE_FROM_THE_LOOP: {
        stream = \
                load("res://assets/music/no_escape_from_the_loop.wav") if \
                Utils.get_is_ios_device() else \
                load("res://assets/music/no_escape_from_the_loop.ogg"),
        text = "NO_ESCAPE_FROM_THE_LOOP",
        volume_db = -0.0,
    },
    OUT_FOR_A_LOOP_RIDE: {
        stream = \
                load("res://assets/music/out_for_a_loop_ride.wav") if \
                Utils.get_is_ios_device() else \
                load("res://assets/music/out_for_a_loop_ride.ogg"),
        text = "OUT_FOR_A_LOOP_RIDE",
        volume_db = -0.0,
    },
    STUCK_IN_A_CREVASSE: {
        stream = \
                load("res://assets/music/stuck_in_a_crevasse.wav") if \
                Utils.get_is_ios_device() else \
                load("res://assets/music/stuck_in_a_crevasse.ogg"),
        text = "STUCK_IN_A_CREVASSE",
        volume_db = -0.0,
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
