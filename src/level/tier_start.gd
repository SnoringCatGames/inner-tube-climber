tool
extends TierTerminus
class_name TierStart

var SURFACE_COLOR := Color.from_hsv(0.47, 0.7, 0.9, 0.5)

export var spawn_position_x: float = 0.0 setget _set_spawn_position_x

var spawn_position: Vector2 setget ,_get_spawn_position

func _init().(SURFACE_COLOR) -> void:
    pass

func _set_spawn_position_x(value: float) -> void:
    spawn_position_x = value
    update()

func _get_spawn_position() -> Vector2:
    return Vector2(spawn_position_x, 0.0)

func update() -> void:
    var horizontal_extent := width * 0.5
    spawn_position_x = clamp( \
            spawn_position_x, \
            -horizontal_extent, \
            horizontal_extent)

func _draw() -> void:
    if Engine.editor_hint:
        var spawn_position := Vector2( \
                spawn_position_x, \
                0.0)
        draw_circle( \
                spawn_position, \
                12.0, \
                SURFACE_COLOR)

func get_x_start() -> float:
    return position.x - width * 0.5

func get_x_end() -> float:
    return position.x + width * 0.5
