tool
extends HBoxContainer
class_name KeyValueRow

export var key: String setget _set_key,_get_key
export var value: String setget _set_value,_get_value

func _set_key(k: String) -> void:
    $Key.text = k

func _get_key() -> String:
    return $Key.text

func _set_value(v: String) -> void:
    $Value.text = v

func _get_value() -> String:
    return $Value.text
