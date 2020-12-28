tool
extends Node2D
class_name Torch

const LIGHT_ENERGY_DEFAULT := 0.95

const FLICKER_PERIOD_MIN_SEC := 0.05
const FLICKER_PERIOD_MAX_SEC := 0.5

const FLICKER_ENERGY_MIN := 0.5
const FLICKER_ENERGY_MAX := 0.9

const FLICKER_DURATION_MIN_SEC := 0.005
const FLICKER_DURATION_MAX_SEC := 0.02

var windiness: Vector2 setget _set_windiness

var _last_flicker_end_time_sec := -INF
var _next_flicker_start_time_sec := -INF
var _is_mid_flicker := false

func _ready() -> void:
    var current_time_sec: float = \
            OS.get_ticks_msec() / 1000.0 if \
            Engine.editor_hint else \
            Time.elapsed_play_time_actual_sec
    _last_flicker_end_time_sec = current_time_sec
    _next_flicker_start_time_sec = current_time_sec
    $Light2D.energy = LIGHT_ENERGY_DEFAULT

func _process(delta_sec: float) -> void:
    var current_time_sec: float = \
            OS.get_ticks_msec() / 1000.0 if \
            Engine.editor_hint else \
            Time.elapsed_play_time_actual_sec
    
    if current_time_sec > _last_flicker_end_time_sec and \
            _is_mid_flicker:
        _is_mid_flicker = false
        $Light2D.energy = LIGHT_ENERGY_DEFAULT
    
    if current_time_sec > _next_flicker_start_time_sec:
        _is_mid_flicker = true
        
        var flicker_energy: float = lerp( \
                FLICKER_ENERGY_MIN, \
                FLICKER_ENERGY_MAX, \
                randf())
        $Light2D.energy = flicker_energy
        
        var flicker_duration_sec: float = lerp( \
                FLICKER_DURATION_MIN_SEC, \
                FLICKER_DURATION_MAX_SEC, \
                randf())
        _last_flicker_end_time_sec = \
                _next_flicker_start_time_sec + flicker_duration_sec
        
        var flicker_period_sec: float = lerp( \
                FLICKER_PERIOD_MIN_SEC, \
                FLICKER_PERIOD_MAX_SEC, \
                randf())
        _next_flicker_start_time_sec = \
                _next_flicker_start_time_sec + flicker_period_sec

func _set_windiness(value: Vector2) -> void:
    $TorchFlame.windiness = value
