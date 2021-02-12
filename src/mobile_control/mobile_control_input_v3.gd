# These are multi-touch controls.
# 
# -   There are two distinct regions of interaction: the left half of the
#     screen and the right half, divided evenly down the middle.
# -   The left region triggers jumping.
#     -   Jump is triggered on touch-down.
# -   The right region triggers sideways movement.
#     -   Sideways movement is controlled by gestures, rather than distinct
#         sub-regions corresponding to left or right.
#     -   If enough net horizontal drag movement has occurred, relative to the
#         original touch-down position, then the sideways movement is triggered.
#     -   The sideways movement trigger ends on touch-up or when enough net
#         horizontal drag movement occurs in the opposite direction.
extends MobileControlInputV1
class_name MobileControlInputV3

func _handle_move_sideways_drag(pointer_position: Vector2) -> void:
    move_sideways_pointer_current_position = pointer_position
    
    _update_position_and_time_buffer(pointer_position)
    var newest_drag_position: PositionAndTime = \
            recent_gesture_positions.front()
    var position_relative_to_pointer_down: Vector2 = \
            newest_drag_position.position - move_sideways_pointer_down_position
    
    var is_move_left_triggered_from_gesture := \
            position_relative_to_pointer_down.x < 0.0
    var is_move_right_triggered_from_gesture := \
            position_relative_to_pointer_down.x > 0.0
    
    if is_move_left_triggered_from_gesture:
        is_move_left_pressed = true
        is_move_right_pressed = false
    elif is_move_right_triggered_from_gesture:
        is_move_left_pressed = false
        is_move_right_pressed = true

func get_pointer_down_position_to_annotate() -> Vector2:
    return move_sideways_pointer_down_position
