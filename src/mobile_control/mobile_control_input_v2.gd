# This is a single-touch control.
# 
# -   Pressing by itself does nothing.
# -   Swiping up triggers a jump.
# -   Swiping left or right triggers movement in that direction.
# -   At the start of a gesture, an angled swipe will _not_ trigger both jump
#     and sideways movement simultaneously.
#     -   Instead, jump movement is given priority over sideways movement.
#     -   After a slight delay, sideways movement is then allowed.
extends MobileControlInput
class_name MobileControlInputV2

const GESTURE_VELOCITY_THRESHOLD_INCHES_PER_SEC := Vector2(0.9, 1.12)
const REVERSE_GESTURE_VELOCITY_THRESHOLD_INCHES_PER_SEC := Vector2(1.6, 1.6)

var gesture_velocity_threshold_pixels_per_sec: Vector2 = \
        GESTURE_VELOCITY_THRESHOLD_INCHES_PER_SEC * Utils.get_viewport_ppi()
var reverse_gesture_velocity_threshold_pixels_per_sec: Vector2 = \
        REVERSE_GESTURE_VELOCITY_THRESHOLD_INCHES_PER_SEC * Utils.get_viewport_ppi()

const POST_JUMP_START_SIDEWAYS_MOVEMENT_DELAY := 0.08
const POST_SIDEWAYS_MOVEMENT_START_JUMP_DELAY := 0.02

var gesture_start_time_sec := INF

var jump_pointer_current_position := Vector2.INF
var move_sideways_pointer_current_position := Vector2.INF

func _input(event: InputEvent) -> void:
    var type_and_position := _get_event_type_and_position(event)
    var event_type: int = type_and_position[0]
    var pointer_position: Vector2 = type_and_position[1]
    
    if event_type == PointerEventType.DOWN or \
            event_type == PointerEventType.DRAG:
        _update_position_and_time_buffer(pointer_position)
        var gesture_velocity := _get_velocity()
        
        var is_gesture_already_started := gesture_start_time_sec != INF
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
        var is_velocity_enough_to_start_move_sideways := \
                is_velocity_enough_to_start_move_left or \
                is_velocity_enough_to_start_move_right
        var is_velocity_more_vertical_than_horizontal := \
                abs(gesture_velocity.y) > abs(gesture_velocity.x)
        
        if !is_gesture_already_started:
            assert(!is_jump_pressed and \
                    !is_move_left_pressed and \
                    !is_move_right_pressed)
            
            if is_velocity_enough_to_start_jump or \
                    is_velocity_enough_to_start_move_sideways:
                gesture_start_time_sec = Time.elapsed_play_time_sec
                
                if is_velocity_enough_to_start_jump and \
                        is_velocity_enough_to_start_move_sideways:
                    if is_velocity_more_vertical_than_horizontal:
                        is_jump_pressed = true
                    elif is_velocity_enough_to_start_move_left:
                        is_move_left_pressed = true
                    else:
                        is_move_right_pressed = true
                elif is_velocity_enough_to_start_jump:
                    is_jump_pressed = true
                elif is_velocity_enough_to_start_move_left:
                    is_move_left_pressed = true
                elif is_velocity_enough_to_start_move_right:
                    is_move_right_pressed = true
            
        else:
            if is_jump_pressed:
                var is_delay_enough_to_start_move_sideways := \
                        gesture_start_time_sec + \
                                POST_JUMP_START_SIDEWAYS_MOVEMENT_DELAY < \
                        Time.elapsed_play_time_sec
                
                if is_velocity_enough_to_start_move_sideways and \
                        is_delay_enough_to_start_move_sideways:
                    if is_velocity_enough_to_start_move_left:
                        is_move_left_pressed = true
                        is_move_right_pressed = false
                    else:
                        is_move_right_pressed = true
                        is_move_left_pressed = false
                
                if is_velocity_enough_to_end_jump:
                    is_jump_pressed = false
                    if !is_move_left_pressed and !is_move_right_pressed:
                        recent_gesture_positions.clear()
                        is_positions_buffer_dirty = true
                        gesture_start_time_sec = INF
                
            elif is_move_left_pressed or is_move_right_pressed:
                var is_delay_enough_to_keep_move_sideways := \
                        gesture_start_time_sec + \
                                POST_SIDEWAYS_MOVEMENT_START_JUMP_DELAY < \
                        Time.elapsed_play_time_sec
                
                if is_velocity_enough_to_start_jump:
                    is_jump_pressed = true
                    
                    if !is_delay_enough_to_keep_move_sideways:
                        is_move_left_pressed = false
                        is_move_right_pressed = false
                
                # Switching directions?
                if is_velocity_enough_to_start_move_left and \
                        is_move_right_pressed:
                    is_move_left_pressed = true
                    is_move_right_pressed = false
                elif is_velocity_enough_to_start_move_right and \
                        is_move_left_pressed:
                    is_move_left_pressed = false
                    is_move_right_pressed = true
                
            else:
                Utils.error()
        
        if is_jump_pressed:
            jump_pointer_current_position = pointer_position
        else:
            jump_pointer_current_position = Vector2.INF
        
        if is_move_left_pressed or is_move_right_pressed:
            move_sideways_pointer_current_position = pointer_position
        else:
            move_sideways_pointer_current_position = Vector2.INF
        
    elif event_type == PointerEventType.UP:
        is_jump_pressed = false
        is_move_left_pressed = false
        is_move_right_pressed = false
        recent_gesture_positions.clear()
        is_positions_buffer_dirty = true
        latest_gesture_position = Vector2.INF
        jump_pointer_current_position = Vector2.INF
        move_sideways_pointer_current_position = Vector2.INF
        gesture_start_time_sec = INF
