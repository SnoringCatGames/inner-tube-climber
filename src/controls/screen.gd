extends Node2D
class_name Screen

var type := ScreenType.UNKNOWN

func _init(type: int) -> void:
    self.type = type
