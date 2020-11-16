extends Node2D
class_name Screen

var type := ScreenType.UNKNOWN

func _init(type: int) -> void:
    self.type = type

func _on_activated() -> void:
    pass

func _on_deactivated() -> void:
    pass
