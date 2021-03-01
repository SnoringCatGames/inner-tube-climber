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
extends MobileControlInputV1
class_name MobileControlInputV2

const GESTURE_VELOCITY_THRESHOLD_INCHES_PER_SEC := Vector2(0.16, 0.16)
const REVERSE_GESTURE_VELOCITY_THRESHOLD_INCHES_PER_SEC := Vector2(0.96, 0.48)

var gesture_velocity_threshold_pixels_per_sec: Vector2 = \
        GESTURE_VELOCITY_THRESHOLD_INCHES_PER_SEC * Utils.get_viewport_ppi()
var reverse_gesture_velocity_threshold_pixels_per_sec: Vector2 = \
        REVERSE_GESTURE_VELOCITY_THRESHOLD_INCHES_PER_SEC * \
        Utils.get_viewport_ppi()

func _init(is_jump_on_left_side: bool).(is_jump_on_left_side) -> void:
    pass

func _handle_move_sideways_drag(pointer_position: Vector2) -> void:
    move_sideways_pointer_current_position = pointer_position
    
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
