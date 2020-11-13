extends Node2D
class_name TierRatioSign

var text: String setget _set_text,_get_text

func _set_text(value: String) -> void:
    $Label.text = value

func _get_text() -> String:
    return $Label.text
