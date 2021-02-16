extends Node

const MUSIC_CROSS_FADE_DURATION_SEC := 2.0
const SILENT_VOLUME_DB := -80.0

const GLOBAL_AUDIO_VOLUME_OFFSET_DB := -20.0

const MAIN_MENU_MUSIC_PLAYER_INDEX := 3
const GAME_OVER_MUSIC_PLAYER_INDEX := 2

const START_MUSIC_INDEX := 0

var MUSIC_PLAYERS = [
    Music.get_player(Music.STUCK_IN_A_CREVASSE),
    Music.get_player(Music.NO_ESCAPE_FROM_THE_LOOP),
    Music.get_player(Music.RISING_THROUGH_RARIFIED_AIR),
    Music.get_player(Music.OUT_FOR_A_LOOP_RIDE),
    Music.get_player(Music.PUMP_UP_THAT_TUBE),
]

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
    pitch_shift_effect = AudioEffectPitchShift.new()
    AudioServer.add_bus_effect(Music.MUSIC_BUS_INDEX, pitch_shift_effect)
    
    _update_volume()

func play_sound(sound: int) -> void:
    call_deferred("_play_sound_deferred", sound)

func _play_sound_deferred(sound: int) -> void:
    Sound.MANIFEST[sound].player.play()

func cross_fade_music( \
        next_music_player_index: int, \
        transitions_immediately := false) -> void:
    call_deferred( \
            "_cross_fade_music_deferred", \
            next_music_player_index, \
            transitions_immediately)

func _cross_fade_music_deferred( \
        next_music_player_index: int, \
        transitions_immediately := false) -> void:
    if fade_out_tween != null:
        on_cross_fade_music_finished()
    if previous_music_player != null and \
            previous_music_player.playing:
        # TODO: This shouldn't happen, but it does sometimes.
        pass
    
    var next_music_player: AudioStreamPlayer = \
            MUSIC_PLAYERS[next_music_player_index]
    previous_music_player = current_music_player
    current_music_player = next_music_player
    
    if previous_music_player == current_music_player and \
            current_music_player.playing:
        return
    
    var transition_duration_sec := \
            0.01 if \
            transitions_immediately else \
            MUSIC_CROSS_FADE_DURATION_SEC
    
    if previous_music_player != null and \
            previous_music_player.playing:
        var previous_loud_volume := \
                Music.get_volume_for_player(previous_music_player) + \
                        GLOBAL_AUDIO_VOLUME_OFFSET_DB if \
                is_music_enabled else \
                SILENT_VOLUME_DB
        fade_out_tween = Tween.new()
        add_child(fade_out_tween)
        fade_out_tween.interpolate_property( \
                previous_music_player, \
                "volume_db", \
                previous_loud_volume, \
                SILENT_VOLUME_DB, \
                transition_duration_sec, \
                Tween.TRANS_QUAD, \
                Tween.EASE_IN)
        fade_out_tween.start()
    
    set_playback_speed(current_playback_speed)
    current_music_player.volume_db = SILENT_VOLUME_DB
    current_music_player.play()
    
    var current_loud_volume := \
            Music.get_volume_for_player(current_music_player) + \
                    GLOBAL_AUDIO_VOLUME_OFFSET_DB if \
            is_music_enabled else \
            SILENT_VOLUME_DB
    fade_in_tween = Tween.new()
    add_child(fade_in_tween)
    fade_in_tween.interpolate_property( \
            current_music_player, \
            "volume_db", \
            SILENT_VOLUME_DB, \
            current_loud_volume, \
            transition_duration_sec, \
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
        fade_out_tween.queue_free()
        fade_out_tween = null
        if previous_music_player != null:
            previous_music_player.volume_db = SILENT_VOLUME_DB
    if fade_in_tween != null:
        fade_in_tween.queue_free()
        fade_in_tween = null
        if current_music_player != null:
            var loud_volume := \
                    Music.get_volume_for_player(current_music_player) + \
                            GLOBAL_AUDIO_VOLUME_OFFSET_DB if \
                    is_music_enabled else \
                    SILENT_VOLUME_DB
            current_music_player.volume_db = loud_volume
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
    for config in Music.MANIFEST.values():
        config.player.volume_db = \
                config.volume_db + GLOBAL_AUDIO_VOLUME_OFFSET_DB if \
                is_music_enabled else \
                SILENT_VOLUME_DB
    
    for config in Sound.MANIFEST.values():
        config.player.volume_db = \
                config.volume_db + GLOBAL_AUDIO_VOLUME_OFFSET_DB if \
                is_sound_effects_enabled else \
                SILENT_VOLUME_DB
