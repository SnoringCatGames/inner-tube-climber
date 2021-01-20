tool
extends PanelContainer
class_name KeyValueRow

export var key: String setget _set_key,_get_key
export var value: String setget _set_value,_get_value
export var is_odd_row := true setget _set_is_odd_row,_get_is_odd_row

func _set_key(k: String) -> void:
    $HBoxContainer/Key.text = k

func _get_key() -> String:
    return $HBoxContainer/Key.text

func _set_value(v: String) -> void:
    $HBoxContainer/Value.text = v

func _get_value() -> String:
    return $HBoxContainer/Value.text

func _set_is_odd_row(is_odd: bool) -> void:
    is_odd_row = is_odd
    if !is_odd_row:
        var style := StyleBoxFlat.new()
        style.bg_color = Constants.KEY_VALUE_EVEN_ROW_COLOR
        add_stylebox_override("panel", style)

func _get_is_odd_row() -> bool:
    return is_odd_row
