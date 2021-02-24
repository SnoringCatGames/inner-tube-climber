tool
extends Node2D
class_name SpawnPositionOverride

var SURFACE_COLOR := Color.from_hsv(0.47, 0.7, 0.9, 0.5)

func _init() -> void:
    pass

func _ready() -> void:
    update()

func _draw() -> void:
    if Engine.editor_hint:
        draw_circle( \
                Vector2.ZERO, \
                24.0, \
                SURFACE_COLOR)
