tool
extends Panel
class_name ScoreBoard

const NUMBER_TWEEN_DURATION_PER_NUMBER_SEC := 1.0 / 40.0
const NUMBER_TWEEN_MAX_TOTAL_DURATION_SEC := 6.0

export var label: String setget _set_label,_get_label
export var value: String setget _set_value,_get_value

var is_ready := false

var is_using_number_tweens := false
var number: int = 0
var previous_tween_number: int = 0
# Array<Tween>
var number_tweens := []

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
        # FIXME: ------------------------ Try triggering sound effect.
        pass
    
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
