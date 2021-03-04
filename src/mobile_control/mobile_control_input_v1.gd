# These are multi-touch controls.
# 
# -   There are two distinct regions of interaction: the left half of the
#     screen and the right half, divided evenly down the middle.
# -   The left region triggers jumping.
#     -   Jump is triggered on touch-down.
# -   The right region triggers sideways movement.
#     -   Sideways movement is controlled by gestures, rather than distinct
#         sub-regions corresponding to left or right.
#     -   If enough net horizontal drag movement has occurred recently, since
#         any drag amount in the other direction, then the sideways movement
#         is triggered.
#     -   The sideways movement trigger ends on touch-up or when enough net
#         horizontal drag movement occurs in the opposite direction.
extends MobileControlInput
class_name MobileControlInputV1

const JUMP_SIDE_SCREEN_WIDTH_RATIO := 0.35

const GESTURE_VELOCITY_THRESHOLD_INCHES := Vector2(0.09, 0.09)
const REVERSE_GESTURE_VELOCITY_THRESHOLD_INCHES := Vector2(0.16, 0.08)

var gesture_velocity_threshold_pixels: Vector2 = \
        GESTURE_VELOCITY_THRESHOLD_INCHES * Utils.get_viewport_ppi()
var reverse_gesture_velocity_threshold_pixels: Vector2 = \
        REVERSE_GESTURE_VELOCITY_THRESHOLD_INCHES * \
        Utils.get_viewport_ppi()

var is_jump_on_left_side: bool

var is_move_sideways_pressed := false

var jump_pointer_current_position := Vector2.INF
var move_sideways_pointer_current_position := Vector2.INF

var jump_pointer_down_position := Vector2.INF
var move_sideways_pointer_down_position := Vector2.INF

func _init(is_jump_on_left_side: bool).() -> void:
    self.is_jump_on_left_side = is_jump_on_left_side

func _unhandled_input(event: InputEvent) -> void:
    var type_and_position := _get_event_type_and_position(event)
    var event_type: int = type_and_position[0]
    var pointer_position: Vector2 = type_and_position[1]
    
    var is_event_on_jump_side_of_screen: bool = \
            pointer_position != Vector2.INF and \
            (pointer_position.x < \
                    get_viewport().size.x * JUMP_SIDE_SCREEN_WIDTH_RATIO if \
            is_jump_on_left_side else \
            pointer_position.x > \
                    get_viewport().size.x * (1 - JUMP_SIDE_SCREEN_WIDTH_RATIO))
    
    var is_event_closer_to_previous_jump_than_move_sideways: bool
    if jump_pointer_current_position != Vector2.INF and \
            move_sideways_pointer_current_position != Vector2.INF:
        is_event_closer_to_previous_jump_than_move_sideways = \
                pointer_position.distance_squared_to( \
                        jump_pointer_current_position) < \
                pointer_position.distance_squared_to( \
                        move_sideways_pointer_current_position)
    elif jump_pointer_current_position != Vector2.INF:
        is_event_closer_to_previous_jump_than_move_sideways = true
    else:
        is_event_closer_to_previous_jump_than_move_sideways = false
    
    var is_a_jump_event := \
            is_jump_pressed and \
                    (!is_move_sideways_pressed or \
                    is_event_closer_to_previous_jump_than_move_sideways)
    var is_a_move_sideways_event := \
            is_move_sideways_pressed and \
                    (!is_jump_pressed or \
                    !is_event_closer_to_previous_jump_than_move_sideways)
    
    if event_type == PointerEventType.DOWN:
        if is_event_on_jump_side_of_screen:
            is_jump_pressed = true
            jump_pointer_down_position = pointer_position
            jump_pointer_current_position = pointer_position
        else:
            is_move_sideways_pressed = true
            move_sideways_pointer_down_position = pointer_position
            _handle_move_sideways_drag(pointer_position)
        
    elif event_type == PointerEventType.DRAG:
        if is_a_jump_event:
            jump_pointer_current_position = pointer_position
        elif is_a_move_sideways_event:
            _handle_move_sideways_drag(pointer_position)
        else:
            # There was no corresponding down event for this drag event.
            # This can happen when a finger is pressed while the level starts.
            # Or this could possibly happen if Godot somehow misses the down
            # event?
            if Time.elapsed_play_time_actual_sec > start_time_sec + 0.5:
                if is_event_on_jump_side_of_screen:
                    is_jump_pressed = true
                    jump_pointer_down_position = pointer_position
                    jump_pointer_current_position = pointer_position
                else:
                    is_move_sideways_pressed = true
                    move_sideways_pointer_down_position = pointer_position
                    _handle_move_sideways_drag(pointer_position)
        
    elif event_type == PointerEventType.UP:
        if is_a_jump_event:
            is_jump_pressed = false
            jump_pointer_down_position = Vector2.INF
            jump_pointer_current_position = Vector2.INF
        elif is_a_move_sideways_event:
            is_move_left_pressed = false
            is_move_right_pressed = false
            recent_gesture_positions.clear()
            is_positions_buffer_dirty = true
            latest_gesture_position = Vector2.INF
            latest_leftward_position = Vector2.INF
            latest_rightward_position = Vector2.INF
            move_sideways_pointer_down_position = Vector2.INF
            move_sideways_pointer_current_position = Vector2.INF
        else:
            # There was no corresponding down event for this up event?
            # This can happen when a finger is pressed while the level starts.
            pass

func _handle_move_sideways_drag(pointer_position: Vector2) -> void:
    move_sideways_pointer_current_position = pointer_position
    
    _update_position_and_time_buffer(pointer_position)
    
    var recent_displacement := _get_displacement_since_other_direction()
    var is_move_left_triggered_from_gesture := \
            recent_displacement.x < \
            -reverse_gesture_velocity_threshold_pixels.x if \
            is_move_right_pressed else \
            recent_displacement.x < \
            -gesture_velocity_threshold_pixels.x
    var is_move_right_triggered_from_gesture := \
            recent_displacement.x > \
            reverse_gesture_velocity_threshold_pixels.x if \
            is_move_left_pressed else \
            recent_displacement.x > \
            gesture_velocity_threshold_pixels.x
    
    if is_move_left_triggered_from_gesture:
        is_move_left_pressed = true
        is_move_right_pressed = false
    elif is_move_right_triggered_from_gesture:
        is_move_left_pressed = false
        is_move_right_pressed = true
