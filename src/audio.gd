extends Node

const MUSIC_STREAM_0 := \
        preload("res://assets/music/stuck_in_a_crevasse.ogg")
const MUSIC_STREAM_1 := \
        preload("res://assets/music/no_escape_from_the_loop.ogg")
const MUSIC_STREAM_2 := \
        preload("res://assets/music/out_for_a_loop_ride.ogg")

const BUTTON_PRESS_SFX_STREAM := preload("res://assets/sfx/menu_select.wav")
const GAME_OVER_SFX_STREAM := preload("res://assets/sfx/yeti_yell.wav")
const NEW_TIER_SFX_STREAM := preload("res://assets/sfx/new_tier.wav")
const JUMP_SFX_STREAM := preload("res://assets/sfx/tuber_jump.wav")
const LAND_SFX_STREAM := preload("res://assets/sfx/tuber_land.wav")
const BOUNCE_SFX_STREAM := preload("res://assets/sfx/tuber_bounce.wav")

const MUSIC_CROSS_FADE_DURATION_SEC := 2.0
const MUSIC_SILENT_VOLUME_DB := -80.0

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

var previous_music_player: AudioStreamPlayer
var current_music_player: AudioStreamPlayer

func _init() -> void:
    _init_audio_players()

func _init_audio_players() -> void:
    MUSIC_PLAYERS[0].stream = MUSIC_STREAM_0
    MUSIC_PLAYERS[0].volume_db = -0.0
    add_child(MUSIC_PLAYERS[0])
    MUSIC_PLAYERS[1].stream = MUSIC_STREAM_1
    MUSIC_PLAYERS[1].volume_db = -0.0
    add_child(MUSIC_PLAYERS[1])
    MUSIC_PLAYERS[2].stream = MUSIC_STREAM_2
    MUSIC_PLAYERS[2].volume_db = -0.0
    add_child(MUSIC_PLAYERS[2])
    
    button_press_sfx_player = AudioStreamPlayer.new()
    button_press_sfx_player.stream = BUTTON_PRESS_SFX_STREAM
    button_press_sfx_player.volume_db = -6.0
    add_child(button_press_sfx_player)
    
    jump_sfx_player = AudioStreamPlayer.new()
    jump_sfx_player.stream = JUMP_SFX_STREAM
    jump_sfx_player.volume_db = -6.0
    add_child(jump_sfx_player)
    
    land_sfx_player = AudioStreamPlayer.new()
    land_sfx_player.stream = LAND_SFX_STREAM
    land_sfx_player.volume_db = -0.0
    add_child(land_sfx_player)
    
    bounce_sfx_player = AudioStreamPlayer.new()
    bounce_sfx_player.stream = BOUNCE_SFX_STREAM
    bounce_sfx_player.volume_db = -2.0
    add_child(bounce_sfx_player)
    
    game_over_sfx_player = AudioStreamPlayer.new()
    game_over_sfx_player.stream = GAME_OVER_SFX_STREAM
    game_over_sfx_player.volume_db = -6.0
    add_child(game_over_sfx_player)
    
    new_tier_sfx_player = AudioStreamPlayer.new()
    new_tier_sfx_player.stream = NEW_TIER_SFX_STREAM
    new_tier_sfx_player.volume_db = -6.0
    add_child(new_tier_sfx_player)

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
    
    if previous_music_player != null and previous_music_player.playing:
        fade_out_tween = Tween.new()
        add_child(fade_out_tween)
        fade_out_tween.interpolate_property( \
                previous_music_player, \
                "volume_db", \
                0.0, \
                MUSIC_SILENT_VOLUME_DB, \
                MUSIC_CROSS_FADE_DURATION_SEC, \
                Tween.TRANS_QUAD, \
                Tween.EASE_IN)
        fade_out_tween.start()
    
    current_music_player.volume_db = MUSIC_SILENT_VOLUME_DB
    current_music_player.play()
    
    fade_in_tween = Tween.new()
    add_child(fade_in_tween)
    fade_in_tween.interpolate_property( \
            current_music_player, \
            "volume_db", \
            MUSIC_SILENT_VOLUME_DB, \
            0.0, \
            MUSIC_CROSS_FADE_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_OUT)
    fade_in_tween.start()
    
    fade_in_tween.connect( \
            "tween_completed", \
            self, \
            "on_cross_fade_music_finished")

func on_cross_fade_music_finished() -> void:
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
