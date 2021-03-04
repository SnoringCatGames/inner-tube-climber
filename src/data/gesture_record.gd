extends Node2D
class_name GestureRecord

# Array<GestureEventForDebugging>
var recent_gesture_events_for_debugging := []

func _input(event: InputEvent) -> void:
    if (Constants.DEBUG or Constants.PLAYTEST) and \
            (event is InputEventScreenTouch or event is InputEventScreenDrag):
        _record_new_gesture_event(event)

func _record_new_gesture_event(event: InputEvent) -> void:
    var gesture_name: String
    if event is InputEventScreenTouch:
        gesture_name = "do" if event.pressed else "up"
    elif event is InputEventScreenDrag:
        gesture_name = "dr"
    else:
        Utils.error()
        return
    var gesture_event := GestureEventForDebugging.new( \
            event.position, \
            gesture_name, \
            Time.elapsed_play_time_actual_sec)
    recent_gesture_events_for_debugging.push_front(gesture_event)
    while recent_gesture_events_for_debugging.size() > \
            Constants.RECENT_GESTURE_EVENTS_FOR_DEBUGGING_BUFFER_SIZE:
        recent_gesture_events_for_debugging.pop_back()
