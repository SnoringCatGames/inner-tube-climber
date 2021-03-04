extends Reference
class_name MovementEventForDebugging

var name: String
var time_sec: float

func _init( \
        name: String, \
        time_sec: float) -> void:
    self.name = name
    self.time_sec = time_sec

func to_string() -> String:
    return "{%s;%.3f}" % [
        name,
        time_sec,
    ]
