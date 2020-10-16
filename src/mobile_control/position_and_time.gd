extends Reference
class_name PositionAndTime

var position: Vector2
var time_sec: float

func _init( \
        position: Vector2, \
        time_sec: float) -> void:
    self.position = position
    self.time_sec = time_sec
