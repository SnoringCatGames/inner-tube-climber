# This is a single-touch control.
# 
# -   Pressing by itself does nothing.
# -   Swiping up triggers a jump.
# -   Swiping left or right triggers movement in that direction.
extends MobileControlInput
class_name MobileControlInputV2

const GESTURE_VELOCITY_THRESHOLD_INCHES_PER_SEC := Vector2(0.45, 0.56)
const REVERSE_GESTURE_VELOCITY_THRESHOLD_INCHES_PER_SEC := Vector2(0.8, 0.8)

var gesture_velocity_threshold_pixels_per_sec: Vector2 = \
        GESTURE_VELOCITY_THRESHOLD_INCHES_PER_SEC * Utils.get_ppi()
var reverse_gesture_velocity_threshold_pixels_per_sec: Vector2 = \
        REVERSE_GESTURE_VELOCITY_THRESHOLD_INCHES_PER_SEC * Utils.get_ppi()

func _input(event: InputEvent) -> void:
    var type_and_position := _get_event_type_and_position(event)
    var event_type: int = type_and_position[0]
    var pointer_position: Vector2 = type_and_position[1]
    
    if event_type == PointerEventType.DOWN or \
            event_type == PointerEventType.DRAG:
        _update_position_and_time_buffer(pointer_position)
        var gesture_velocity := _get_velocity()
        
        var is_velocity_enough_to_start_jump := \
                gesture_velocity.y < \
                -gesture_velocity_threshold_pixels_per_sec.y
        var is_velocity_enough_to_end_jump := \
                gesture_velocity.y > \
                reverse_gesture_velocity_threshold_pixels_per_sec.y
        var is_velocity_enough_to_start_move_left := \
                gesture_velocity.x < \
                -reverse_gesture_velocity_threshold_pixels_per_sec.x if \
                is_move_right_pressed else \
                gesture_velocity.x < \
                -gesture_velocity_threshold_pixels_per_sec.x
        var is_velocity_enough_to_start_move_right := \
                gesture_velocity.x > \
                reverse_gesture_velocity_threshold_pixels_per_sec.x if \
                is_move_left_pressed else \
                gesture_velocity.x > \
                gesture_velocity_threshold_pixels_per_sec.x
        
        if is_velocity_enough_to_start_jump:
            is_jump_pressed = true
        elif is_velocity_enough_to_end_jump:
            is_jump_pressed = false
        
        if is_velocity_enough_to_start_move_left:
            is_move_left_pressed = true
            is_move_right_pressed = false
        elif is_velocity_enough_to_start_move_right:
            is_move_right_pressed = true
            is_move_left_pressed = false
        
    elif event_type == PointerEventType.UP:
        is_jump_pressed = false
        is_move_left_pressed = false
        is_move_right_pressed = false
        recent_gesture_positions.clear()
    
#    if Global.is_debug_panel_shown and \
#            event_type != PointerEventType.DRAG and \
#            event_type != PointerEventType.UNKNOWN:
#        Global.debug_panel.add_message((
#                    "%s; " + \
#                    "pos=(%4d,%4d); " + \
#                    "dir=%1d" + \
#                    "buff=%s" + \
##                    "vwprt=(%4d,%4d); " + \
#                    ""
#                ) % [
#                    PointerEventType.get_pointer_event_type_string( \
#                            event_type).substr(0, 2),
#                    pointer_position.x,
#                    pointer_position.y,
#                    drag_direction,
#                    recent_gesture_positions.size(),
##                    get_viewport().size.x,
##                    get_viewport().size.y,
#                ])
