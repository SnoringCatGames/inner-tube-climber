# These are multi-touch controls.
# 
# -   There are two distinct regions of interaction: the left half of the
#     screen and the right half, divided evenly down the middle.
# -   The left region triggers jumping.
#     -   Jump is triggered on touch-down.
# -   The right region triggers sideways movement.
#     -   Sideways movement is controlled by gestures, rather than distinct
#         sub-regions corresponding to left or right.
#     -   If enough net horizontal drag movement has occurred recently, within
#         a small time window, then the sideways movement is triggered.
#     -   The sideways movement trigger ends on touch-up or when enough net
#         horizontal drag movement occurs in the opposite direction.
extends MobileControlInput
class_name MobileControlInputV1

const GESTURE_VELOCITY_THRESHOLD_INCHES_PER_SEC := Vector2(0.02, 0.02)
const REVERSE_GESTURE_VELOCITY_THRESHOLD_INCHES_PER_SEC := Vector2(0.08, 0.04)

var gesture_velocity_threshold_pixels_per_sec: Vector2 = \
        GESTURE_VELOCITY_THRESHOLD_INCHES_PER_SEC * Utils.get_ppi()
var reverse_gesture_velocity_threshold_pixels_per_sec: Vector2 = \
        REVERSE_GESTURE_VELOCITY_THRESHOLD_INCHES_PER_SEC * Utils.get_ppi()

func _input(event: InputEvent) -> void:
    var type_and_position := _get_event_type_and_position(event)
    var event_type: int = type_and_position[0]
    var pointer_position: Vector2 = type_and_position[1]
    
    var is_event_on_jump_side_of_screen: bool = \
            pointer_position != Vector2.INF and \
            pointer_position.x < get_viewport().size.x * 0.5
    
    if is_event_on_jump_side_of_screen:
        if event_type == PointerEventType.DOWN or \
                event_type == PointerEventType.DRAG:
            is_jump_pressed = true
        elif event_type == PointerEventType.UP:
            is_jump_pressed = false
    else:
        if event_type == PointerEventType.DOWN or \
                event_type == PointerEventType.UP:
            is_move_left_pressed = false
            is_move_right_pressed = false
            recent_gesture_positions.clear()
        
        if event_type == PointerEventType.DOWN or \
                event_type == PointerEventType.DRAG:
            _update_position_and_time_buffer(pointer_position)
            var gesture_velocity := _get_velocity()
            
            var is_move_left_triggered_from_gesture := \
                    gesture_velocity.x < \
                    -reverse_gesture_velocity_threshold_pixels_per_sec.x if \
                    is_move_right_pressed else \
                    gesture_velocity.x < \
                    -gesture_velocity_threshold_pixels_per_sec.x
            var is_move_right_triggered_from_gesture := \
                    gesture_velocity.x > \
                    reverse_gesture_velocity_threshold_pixels_per_sec.x if \
                    is_move_left_pressed else \
                    gesture_velocity.x > \
                    gesture_velocity_threshold_pixels_per_sec.x
            
            if is_move_left_triggered_from_gesture:
                is_move_left_pressed = true
                is_move_right_pressed = false
            elif is_move_right_triggered_from_gesture:
                is_move_left_pressed = false
                is_move_right_pressed = true
    
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
