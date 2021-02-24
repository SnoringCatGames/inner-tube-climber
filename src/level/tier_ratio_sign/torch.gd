tool
extends Node2D
class_name Torch

const LIGHT_ENERGY_DEFAULT := 0.95
const LIGHT_ENERGY_INITIAL_BURST := 1.95

const FLICKER_PERIOD_MIN_SEC := 0.05
const FLICKER_PERIOD_MAX_SEC := 0.5

const FLICKER_ENERGY_MIN := 0.5
const FLICKER_ENERGY_MAX := 0.9

const FLICKER_DURATION_MIN_SEC := 0.005
const FLICKER_DURATION_MAX_SEC := 0.02

const LIGHT_INITIAL_BURST_DURATION_SEC := 0.3

export var is_lit := false setget _set_is_lit,_get_is_lit
var windiness: Vector2 setget _set_windiness

var _is_ready := false

var _last_flicker_end_time_sec := -INF
var _next_flicker_start_time_sec := -INF
var _is_mid_flicker := false

var light_burst_tween: Tween

func _ready() -> void:
    _is_ready = true
    
    var current_time_sec: float = \
            OS.get_ticks_msec() / 1000.0 if \
            Engine.editor_hint else \
            Time.elapsed_play_time_actual_sec
    _last_flicker_end_time_sec = current_time_sec
    _next_flicker_start_time_sec = current_time_sec
    $Light2D.energy = LIGHT_ENERGY_DEFAULT
    
    light_burst_tween = Tween.new()
    add_child(light_burst_tween)
    
    if is_lit or Engine.editor_hint:
        ignite(true)
    else:
        snuff()

func ignite(is_bursting := true) -> void:
    $TorchFlame.ignite(is_bursting)
    $Light2D.enabled = true
    if is_bursting:
        var flare_up_duration_sec := LIGHT_INITIAL_BURST_DURATION_SEC * 0.67
        var flare_down_duration_sec := \
                LIGHT_INITIAL_BURST_DURATION_SEC - flare_up_duration_sec
        light_burst_tween.interpolate_property( \
                $Light2D, \
                "energy", \
                0.0, \
                LIGHT_ENERGY_INITIAL_BURST, \
                flare_up_duration_sec, \
                Tween.TRANS_QUART, \
                Tween.EASE_IN_OUT)
        light_burst_tween.interpolate_property( \
                $Light2D, \
                "energy", \
                LIGHT_ENERGY_INITIAL_BURST, \
                LIGHT_ENERGY_DEFAULT, \
                flare_down_duration_sec, \
                Tween.TRANS_QUAD, \
                Tween.EASE_IN_OUT, \
                flare_up_duration_sec)
        light_burst_tween.start()

func snuff() -> void:
    $TorchFlame.snuff()
    $Light2D.enabled = false

func _process(delta_sec: float) -> void:
    if light_burst_tween.is_active():
        return
    
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

func _set_is_lit(value: bool) -> void:
    if is_lit != value:
        is_lit = value
        if _is_ready:
            if is_lit:
                ignite(true)
            else:
                snuff()

func _get_is_lit() -> bool:
    return is_lit
