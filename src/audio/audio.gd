extends Node

const MUSIC_CROSS_FADE_DURATION_SEC := 2.0
const SILENT_VOLUME_DB := -80.0

const GLOBAL_AUDIO_VOLUME_OFFSET_DB := 0.0
#const GLOBAL_AUDIO_VOLUME_OFFSET_DB := -20.0

var fade_out_tween: Tween
var fade_in_tween: Tween

var current_playback_speed := 1.0

var pitch_shift_effect: AudioEffectPitchShift

var previous_music_player: AudioStreamPlayer
var current_music_player: AudioStreamPlayer

var is_music_enabled := true setget _set_is_music_enabled,_get_is_music_enabled
var is_sound_effects_enabled := true setget \
        _set_is_sound_effects_enabled,_get_is_sound_effects_enabled

func _init() -> void:
    pitch_shift_effect = AudioEffectPitchShift.new()
    AudioServer.add_bus_effect(Music.MUSIC_BUS_INDEX, pitch_shift_effect)
    
    fade_out_tween = Tween.new()
    add_child(fade_out_tween)
    fade_in_tween = Tween.new()
    add_child(fade_in_tween)
    
    _update_volume()

func play_sound( \
        sound: int, \
        deferred := false) -> void:
    if deferred:
        call_deferred("_play_sound_deferred", sound)
    else:
        _play_sound_deferred(sound)

func play_music( \
        music_type: int, \
        transitions_immediately := false, \
        deferred := false) -> void:
    if deferred:
        call_deferred( \
                "_cross_fade_music", \
                music_type, \
                transitions_immediately)
    else:
        _cross_fade_music(music_type, transitions_immediately)

func _play_sound_deferred(sound: int) -> void:
    Sound.MANIFEST[sound].player.play()

func _cross_fade_music( \
        music_type: int, \
        transitions_immediately := false) -> void:
    on_cross_fade_music_finished()
    
    if previous_music_player != null and \
            previous_music_player != current_music_player and \
            previous_music_player.playing:
        Utils.error( \
                "Previous music still playing when trying to play new music.")
        previous_music_player.stop()
    
    var next_music_player := Music.get_player(music_type)
    previous_music_player = current_music_player
    current_music_player = next_music_player
    
    if previous_music_player == current_music_player and \
            current_music_player.playing:
        if !fade_in_tween.is_active():
            var loud_volume := \
                    Music.get_volume_for_player(current_music_player) + \
                            GLOBAL_AUDIO_VOLUME_OFFSET_DB if \
                    is_music_enabled else \
                    SILENT_VOLUME_DB
            current_music_player.volume_db = loud_volume
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
    fade_out_tween.stop_all()
    fade_in_tween.stop_all()
    
    if previous_music_player != null and \
            previous_music_player != current_music_player:
        previous_music_player.volume_db = SILENT_VOLUME_DB
        previous_music_player.stop()
    if current_music_player != null:
        var loud_volume := \
                Music.get_volume_for_player(current_music_player) + \
                        GLOBAL_AUDIO_VOLUME_OFFSET_DB if \
                is_music_enabled else \
                SILENT_VOLUME_DB
        current_music_player.volume_db = loud_volume

func set_playback_speed(playback_speed: float) -> void:
    current_playback_speed = playback_speed
    current_music_player.pitch_scale = playback_speed
    pitch_shift_effect.pitch_scale = 1.0 / playback_speed

func _set_is_music_enabled(enabled: bool) -> void:
    is_music_enabled = enabled
    _update_volume()

func _get_is_music_enabled() -> bool:
    return is_music_enabled

func _set_is_sound_effects_enabled(enabled: bool) -> void:
    is_sound_effects_enabled = enabled
    _update_volume()

func _get_is_sound_effects_enabled() -> bool:
    return is_sound_effects_enabled

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
