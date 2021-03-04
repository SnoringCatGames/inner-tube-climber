extends Reference
class_name GestureEventForDebugging

var position: Vector2
var name: String
var time_sec: float

func _init( \
        position: Vector2, \
        name: String, \
        time_sec: float) -> void:
    self.position = position
    self.name = name
    self.time_sec = time_sec

func to_string() -> String:
    return "{%s;(%.2f,%.2f);%.3f}" % [
        name,
        position.x,
        position.y,
        time_sec,
    ]
