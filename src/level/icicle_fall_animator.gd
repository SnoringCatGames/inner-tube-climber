extends Node2D
class_name IcicleFallAnimator

const MIN_TIME_TO_TERMINAL_VELOCITY := 0.1
const MAX_TIME_TO_TERMINAL_VELOCITY := 0.6

const FALL_DURATION := 3.0

var TERMINAL_VELOCITY: float = 1200.0

var is_falling := false
var start_time: float
var icicle_state := []

func fall() -> void:
    assert(icicle_state.empty())
    is_falling = true
    start_time = Time.elapsed_play_time_actual_sec
    var wrappers := $Icicles.get_children()
    for wrapper in wrappers:
        var time_to_terminal_velocity := rand_range( \
                MIN_TIME_TO_TERMINAL_VELOCITY, \
                MAX_TIME_TO_TERMINAL_VELOCITY)
        icicle_state.push_back({
            wrapper = wrapper,
            time_to_terminal_velocity = time_to_terminal_velocity,
            position = Vector2.ZERO,
            velocity = Vector2.ZERO,
        })

func _process(delta_sec: float) -> void:
    if !is_falling:
        return
    
    var current_time := Time.elapsed_play_time_actual_sec
    var elapsed_time := current_time - start_time
    
    var opacity_progress: float = min(elapsed_time / FALL_DURATION, 1.0)
    var opacity := 1.0 - Utils.ease_by_name(opacity_progress, "ease_in_out")
    
    for state in icicle_state:
        var progress := \
                min(elapsed_time / state.time_to_terminal_velocity, 1.0)
        progress = Utils.ease_by_name(progress, "ease_in")
        state.velocity.y = lerp(0.0, TERMINAL_VELOCITY, progress)
        var displacement: Vector2 = state.velocity * delta_sec
        state.position += displacement
        state.wrapper.position = state.position
        state.wrapper.modulate.a = opacity
    
    if Time.elapsed_play_time_actual_sec > start_time + FALL_DURATION:
        is_falling = false
