tool
extends Panel
class_name ScoreBoard

export var label: String setget _set_label,_get_label
export var value: String setget _set_value,_get_value

var is_ready := false

func _ready() -> void:
    is_ready = true
    _set_label(label)
    _set_value(value)

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
