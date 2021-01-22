tool
extends Control
class_name ScoreBoard

const NUMBER_TWEEN_DURATION_PER_NUMBER_SEC := 1.0 / 40.0
const NUMBER_TWEEN_MAX_TOTAL_DURATION_SEC := 6.0

const COLOR_PULSE_DURATION_SEC := 1.0

var FONT_DEFAULT_COLOR := Color.from_hsv(0.0, 0.0, 1.0, 1.0)
var FONT_PULSE_COLOR := \
        Color.from_hsv(Constants.INDICATOR_BLUE_COLOR.h, 0.99, 0.99, 1.0)

export var label: String setget _set_label,_get_label
export var value := "0" setget _set_value,_get_value

var color_tween: Tween

var is_ready := false
var has_initial_value_been_set := false

var is_using_number_tweens := false
var number: int = 0
var previous_tween_number: int = 0
# Array<Tween>
var number_tweens := []

func _enter_tree() -> void:
    color_tween = Tween.new()
    add_child(color_tween)

func _ready() -> void:
    is_ready = true
    _set_label(label)
    _set_value(value)

func _process(delta_sec: float) -> void:
    if !is_using_number_tweens:
        return
    
    var tween_number := number
    for number_tween in number_tweens:
        tween_number -= number_tween.delta - number_tween.number
    
    if tween_number != previous_tween_number:
        _set_value(str(tween_number))
        if visible:
            Audio.play_sound(Sound.SCORE_UPDATE)
    
    previous_tween_number = tween_number

func _set_label(l: String) -> void:
    label = l
    if is_ready:
        $Label.text = l

func _get_label() -> String:
    return label

func _set_value(v: String) -> void:
    value = v
    if is_ready:
        $Value.text = v

func _get_value() -> String:
    return value

func set_value_with_color_pulse(value: String) -> void:
    if value == _get_value():
        return
    
    _set_value(value)
    
    if !has_initial_value_been_set:
        has_initial_value_been_set = true
        return
    
    color_tween.stop(self)
    color_tween.interpolate_method( \
            self, \
            "_on_color_frame", \
            0.0, \
            1.0, \
            COLOR_PULSE_DURATION_SEC, \
            Tween.TRANS_LINEAR, \
            Tween.EASE_IN_OUT)
    color_tween.start()

func _on_color_frame(progress: float) -> void:
    progress = Utils.ease_by_name(progress, "ease_out")
    progress = sin(progress * PI)
    
    var h: float = lerp(FONT_DEFAULT_COLOR.h, FONT_PULSE_COLOR.h, progress)
    var s: float = lerp(FONT_DEFAULT_COLOR.s, FONT_PULSE_COLOR.s, progress)
    var v: float = lerp(FONT_DEFAULT_COLOR.v, FONT_PULSE_COLOR.v, progress)
    var a: float = lerp(FONT_DEFAULT_COLOR.a, FONT_PULSE_COLOR.a, progress)
    var color := Color.from_hsv(h, s, v, a)
    
    $Value.add_color_override("font_color", color)

func animate_to_number(next_number: int) -> void:
    is_using_number_tweens = true
    
    assert(next_number >= number)
    
    if next_number == number:
        return
    
    var number_tween := NumberTween.new(next_number - number)
    add_child(number_tween)
    number_tweens.push_back(number_tween)
    number_tween.connect( \
            "tween_completed", \
            self, \
            "_on_number_tween_completed", \
            [number_tween])
    number_tween.start()
    
    number = next_number

func _on_number_tween_completed( \
        object: Object, \
        key: NodePath, \
        number_tween: Tween) -> void:
    remove_child(number_tween)
    number_tweens.erase(number_tween)
    number_tween.queue_free()

class NumberTween extends Tween:
    var number := 0
    var delta := INF
    
    func _init(delta: int) -> void:
        self.delta = delta
        var duration := NUMBER_TWEEN_DURATION_PER_NUMBER_SEC * delta
        duration = min(duration, NUMBER_TWEEN_MAX_TOTAL_DURATION_SEC)
        self.interpolate_method( \
                self, \
                "_on_frame", \
                0, \
                delta, \
                duration, \
                Tween.TRANS_LINEAR, \
                Tween.EASE_IN_OUT)

    func _on_frame(progress: float) -> void:
        number = round(progress)
