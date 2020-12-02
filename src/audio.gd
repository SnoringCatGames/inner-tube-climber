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

const BUTTON_PRESS_SFX_STREAM := preload("res://assets/sfx/menu_select.wav")
const GAME_OVER_SFX_STREAM := preload("res://assets/sfx/yeti_yell.wav")
const NEW_TIER_SFX_STREAM := preload("res://assets/sfx/new_tier.wav")
const JUMP_SFX_STREAM := preload("res://assets/sfx/tuber_jump.wav")
const LAND_SFX_STREAM := preload("res://assets/sfx/tuber_land.wav")
const BOUNCE_SFX_STREAM := preload("res://assets/sfx/tuber_bounce.wav")

const MUSIC_CROSS_FADE_DURATION_SEC := 2.0
const SILENT_VOLUME_DB := -80.0

const GLOBAL_AUDIO_VOLUME_OFFSET_DB := -20.0

const SFX_BUS_INDEX := 1
const MUSIC_BUS_INDEX := 2

const MAIN_MENU_MUSIC_PLAYER_INDEX := 2

const START_MUSIC_INDEX := 0

var MUSIC_PLAYERS = [
    AudioStreamPlayer.new(),
    AudioStreamPlayer.new(),
    AudioStreamPlayer.new(),
]

var button_press_sfx_player: AudioStreamPlayer
var game_over_sfx_player: AudioStreamPlayer
var new_tier_sfx_player: AudioStreamPlayer
var jump_sfx_player: AudioStreamPlayer
var land_sfx_player: AudioStreamPlayer
var bounce_sfx_player: AudioStreamPlayer

var fade_out_tween: Tween
var fade_in_tween: Tween

var current_music_player_index := START_MUSIC_INDEX

var current_playback_speed := 1.0

var pitch_shift_effect: AudioEffectPitchShift

var previous_music_player: AudioStreamPlayer
var current_music_player: AudioStreamPlayer

var is_music_enabled := true
var is_sound_effects_enabled := true

func _init() -> void:
    _init_audio_players()

func _init_audio_players() -> void:
    AudioServer.add_bus(SFX_BUS_INDEX)
    AudioServer.add_bus(MUSIC_BUS_INDEX)
    
    pitch_shift_effect = AudioEffectPitchShift.new()
    AudioServer.add_bus_effect(MUSIC_BUS_INDEX, pitch_shift_effect)
    
    MUSIC_PLAYERS[0].stream = MUSIC_STREAM_0
    MUSIC_PLAYERS[0].bus = AudioServer.get_bus_name(MUSIC_BUS_INDEX)
    add_child(MUSIC_PLAYERS[0])
    MUSIC_PLAYERS[1].stream = MUSIC_STREAM_1
    MUSIC_PLAYERS[1].bus = AudioServer.get_bus_name(MUSIC_BUS_INDEX)
    add_child(MUSIC_PLAYERS[1])
    MUSIC_PLAYERS[2].stream = MUSIC_STREAM_2
    MUSIC_PLAYERS[2].bus = AudioServer.get_bus_name(MUSIC_BUS_INDEX)
    add_child(MUSIC_PLAYERS[2])
    
    button_press_sfx_player = AudioStreamPlayer.new()
    button_press_sfx_player.stream = BUTTON_PRESS_SFX_STREAM
    button_press_sfx_player.bus = AudioServer.get_bus_name(SFX_BUS_INDEX)
    add_child(button_press_sfx_player)
    
    jump_sfx_player = AudioStreamPlayer.new()
    jump_sfx_player.stream = JUMP_SFX_STREAM
    jump_sfx_player.bus = AudioServer.get_bus_name(SFX_BUS_INDEX)
    add_child(jump_sfx_player)
    
    land_sfx_player = AudioStreamPlayer.new()
    land_sfx_player.stream = LAND_SFX_STREAM
    land_sfx_player.bus = AudioServer.get_bus_name(SFX_BUS_INDEX)
    add_child(land_sfx_player)
    
    bounce_sfx_player = AudioStreamPlayer.new()
    bounce_sfx_player.stream = BOUNCE_SFX_STREAM
    bounce_sfx_player.bus = AudioServer.get_bus_name(SFX_BUS_INDEX)
    add_child(bounce_sfx_player)
    
    game_over_sfx_player = AudioStreamPlayer.new()
    game_over_sfx_player.stream = GAME_OVER_SFX_STREAM
    game_over_sfx_player.bus = AudioServer.get_bus_name(SFX_BUS_INDEX)
    add_child(game_over_sfx_player)
    
    new_tier_sfx_player = AudioStreamPlayer.new()
    new_tier_sfx_player.stream = NEW_TIER_SFX_STREAM
    new_tier_sfx_player.bus = AudioServer.get_bus_name(SFX_BUS_INDEX)
    add_child(new_tier_sfx_player)
    
    _update_volume()

func cross_fade_music(next_music_player_index: int) -> void:
    if fade_out_tween != null:
        on_cross_fade_music_finished()
    if previous_music_player != null and previous_music_player.playing:
        # TODO: This shouldn't happen, but it does sometimes.
        pass
    
    var next_music_player: AudioStreamPlayer = \
            Audio.MUSIC_PLAYERS[next_music_player_index]
    previous_music_player = current_music_player
    current_music_player = next_music_player
    
    if previous_music_player == current_music_player and \
            current_music_player.playing:
        return
    
    var loud_volume := \
            -0.0 + GLOBAL_AUDIO_VOLUME_OFFSET_DB if \
            is_music_enabled else \
            SILENT_VOLUME_DB
    
    if previous_music_player != null and previous_music_player.playing:
        fade_out_tween = Tween.new()
        add_child(fade_out_tween)
        fade_out_tween.interpolate_property( \
                previous_music_player, \
                "volume_db", \
                loud_volume, \
                SILENT_VOLUME_DB, \
                MUSIC_CROSS_FADE_DURATION_SEC, \
                Tween.TRANS_QUAD, \
                Tween.EASE_IN)
        fade_out_tween.start()
    
    set_playback_speed(current_playback_speed)
    current_music_player.volume_db = SILENT_VOLUME_DB
    current_music_player.play()
    
    fade_in_tween = Tween.new()
    add_child(fade_in_tween)
    fade_in_tween.interpolate_property( \
            current_music_player, \
            "volume_db", \
            SILENT_VOLUME_DB, \
            loud_volume, \
            MUSIC_CROSS_FADE_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_OUT)
    fade_in_tween.start()
    
    fade_in_tween.connect( \
            "tween_completed", \
            self, \
            "on_cross_fade_music_finished")

func on_cross_fade_music_finished( \
        _object = null, \
        _key = null) -> void:
    if fade_out_tween != null:
        remove_child(fade_out_tween)
        fade_out_tween.queue_free()
        fade_out_tween = null
    if fade_in_tween != null:
        remove_child(fade_in_tween)
        fade_in_tween.queue_free()
        fade_in_tween = null
    if previous_music_player != null and \
            previous_music_player != current_music_player:
        previous_music_player.stop()

func set_playback_speed(playback_speed: float) -> void:
    current_playback_speed = playback_speed
    current_music_player.pitch_scale = playback_speed
    pitch_shift_effect.pitch_scale = 1.0 / playback_speed

func set_music_enabled(enabled: bool) -> void:
    is_music_enabled = enabled
    _update_volume()

func set_sound_effects_enabled(enabled: bool) -> void:
    is_sound_effects_enabled = enabled
    _update_volume()

func _update_volume() -> void:
    if is_music_enabled:
        MUSIC_PLAYERS[0].volume_db = -0.0 + GLOBAL_AUDIO_VOLUME_OFFSET_DB
        MUSIC_PLAYERS[1].volume_db = -0.0 + GLOBAL_AUDIO_VOLUME_OFFSET_DB
        MUSIC_PLAYERS[2].volume_db = -0.0 + GLOBAL_AUDIO_VOLUME_OFFSET_DB
    else:
        MUSIC_PLAYERS[0].volume_db = SILENT_VOLUME_DB
        MUSIC_PLAYERS[1].volume_db = SILENT_VOLUME_DB
        MUSIC_PLAYERS[2].volume_db = SILENT_VOLUME_DB
    
    if is_sound_effects_enabled:
        button_press_sfx_player.volume_db = -6.0 + GLOBAL_AUDIO_VOLUME_OFFSET_DB
        jump_sfx_player.volume_db = -6.0 + GLOBAL_AUDIO_VOLUME_OFFSET_DB
        land_sfx_player.volume_db = -0.0 + GLOBAL_AUDIO_VOLUME_OFFSET_DB
        bounce_sfx_player.volume_db = -2.0 + GLOBAL_AUDIO_VOLUME_OFFSET_DB
        game_over_sfx_player.volume_db = -6.0 + GLOBAL_AUDIO_VOLUME_OFFSET_DB
        new_tier_sfx_player.volume_db = -6.0 + GLOBAL_AUDIO_VOLUME_OFFSET_DB
    else:
        button_press_sfx_player.volume_db = SILENT_VOLUME_DB
        jump_sfx_player.volume_db = SILENT_VOLUME_DB
        land_sfx_player.volume_db = SILENT_VOLUME_DB
        bounce_sfx_player.volume_db = SILENT_VOLUME_DB
        game_over_sfx_player.volume_db = SILENT_VOLUME_DB
        new_tier_sfx_player.volume_db = SILENT_VOLUME_DB
