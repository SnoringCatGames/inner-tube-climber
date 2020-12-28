extends Node2D
class_name Torch

var windiness: Vector2 setget _set_windiness

func _set_windiness(value: Vector2) -> void:
    $TorchFlame.windiness = value
