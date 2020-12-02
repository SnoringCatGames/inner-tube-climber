extends Annotator
class_name GestureAnnotator

# Array<GestureItem>
var gesture_buffer := []
var mobile_control_input: MobileControlInput

func _init(mobile_control_input: MobileControlInput) -> void:
    self.mobile_control_input = mobile_control_input

func _process(_delta_sec: float) -> void:
    _sync_gesture_buffer()

func _sync_gesture_buffer() -> void:
    # Remove any stale positions.
    var oldest_rendered_gesture_time := \
            Time.elapsed_play_time_actual_sec - GESTURE_POSITION_DURATION_SEC
    while !gesture_buffer.empty() and \
            gesture_buffer.back().time_sec < oldest_rendered_gesture_time:
        var child_annotator: Annotator = gesture_buffer.back().annotator
        remove_child(child_annotator)
        child_annotator.queue_free()
        
        gesture_buffer.pop_back()
    
    # Add any new positions.
    var previous_latest_time_sec: float = \
            gesture_buffer.front().time_sec if \
            !gesture_buffer.empty() else \
            -INF
    for position in mobile_control_input.recent_gesture_positions:
        if position.time_sec > previous_latest_time_sec:
            var action := \
                    "move_left" if \
                    mobile_control_input.is_move_left_pressed else \
                    ("move_right" if \
                    mobile_control_input.is_move_right_pressed else \
                    "unknown")
            var gesture_item := GestureItem.new( \
                    position.position, \
                    position.time_sec, \
                    action)
            gesture_buffer.push_front(gesture_item)
            
            gesture_item.annotator = PulseAnnotator.new( \
                    gesture_item.position, \
                    gesture_item.time_sec, \
                    ACTION_PULSE_PERIOD_SEC, \
                    action_to_direction_angle(gesture_item.action), \
                    ACTION_PULSE_RADIUS_START_PIXELS, \
                    ACTION_PULSE_RADIUS_END_PIXELS, \
                    action_to_color(gesture_item.action), \
                    ACTION_PULSE_OPACITY_START, \
                    ACTION_PULSE_OPACITY_END)
            add_child(gesture_item.annotator)
        else:
            break
    
    # Update radius and opacity values for all gesture positions.
    for item in gesture_buffer:
        var progress: float = \
                (Time.elapsed_play_time_actual_sec - item.time_sec) / \
                GESTURE_POSITION_DURATION_SEC
        progress = Utils.ease_by_name( \
                progress, \
                ACTION_GESTURE_EASING)
        item.annotator.radius_start = lerp( \
                ACTION_PULSE_RADIUS_START_PIXELS * 
                        ACTION_GESTURE_RADIUS_START_MULTIPLIER, \
                ACTION_PULSE_RADIUS_START_PIXELS * \
                        ACTION_GESTURE_RADIUS_END_MULTIPLIER, \
                progress)
        item.annotator.radius_end = lerp( \
                ACTION_PULSE_RADIUS_END_PIXELS * 
                        ACTION_GESTURE_RADIUS_START_MULTIPLIER, \
                ACTION_PULSE_RADIUS_END_PIXELS * \
                        ACTION_GESTURE_RADIUS_END_MULTIPLIER, \
                progress)
        item.annotator.opacity_start = lerp( \
                ACTION_PULSE_OPACITY_START * 
                        ACTION_GESTURE_OPACITY_START_MULTIPLIER, \
                ACTION_PULSE_OPACITY_START * \
                        ACTION_GESTURE_OPACITY_END_MULTIPLIER, \
                progress)
        item.annotator.opacity_end = lerp( \
                ACTION_PULSE_OPACITY_END * 
                        ACTION_GESTURE_OPACITY_START_MULTIPLIER, \
                ACTION_PULSE_OPACITY_END * \
                        ACTION_GESTURE_OPACITY_END_MULTIPLIER, \
                progress)

class GestureItem extends PositionAndTime:
    var action: String
    var annotator: Annotator
    
    func _init( \
            position: Vector2, \
            time_sec: float, \
            action: String).( \
            position, \
            time_sec) -> void:
        self.action = action
