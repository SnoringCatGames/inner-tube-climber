extends Annotator
class_name MobileControlGestureAnnotator

var mobile_control_input: MobileControlInput

var jump_pulse_annotator: PulseAnnotator
var move_sideways_pulse_annotator: PulseAnnotator
var move_sideways_pointer_down_position_pulse_annotator: PulseAnnotator
var gesture_annotator: GestureAnnotator

func _init(mobile_control_input: MobileControlInput) -> void:
    self.mobile_control_input = mobile_control_input

func _process(_delta_sec: float) -> void:
    if Input.is_action_just_pressed("jump") and \
            mobile_control_input.jump_pointer_current_position != Vector2.INF:
        var jump_trigger_annotator := TriggerAnnotator.new( \
                mobile_control_input.jump_pointer_current_position, \
                Time.elapsed_play_time_actual_sec, \
                ACTION_TRIGGER_DURATION_SEC, \
                JUMP_DIRECTION_ANGLE, \
                ACTION_TRIGGER_RADIUS_START_PIXELS, \
                ACTION_TRIGGER_RADIUS_END_PIXELS, \
                Constants.JUMP_COLOR, \
                ACTION_TRIGGER_OPACITY_START, \
                ACTION_TRIGGER_OPACITY_END, \
                ACTION_TRIGGER_EASING)
        _start_child_annotator(jump_trigger_annotator)
        
        if is_instance_valid(jump_pulse_annotator):
            jump_pulse_annotator.emit_signal("finished")
        jump_pulse_annotator = PulseAnnotator.new( \
                mobile_control_input.jump_pointer_current_position, \
                Time.elapsed_play_time_actual_sec, \
                ACTION_PULSE_PERIOD_SEC, \
                JUMP_DIRECTION_ANGLE, \
                ACTION_PULSE_RADIUS_START_PIXELS, \
                ACTION_PULSE_RADIUS_END_PIXELS, \
                Constants.JUMP_COLOR, \
                ACTION_PULSE_OPACITY_START, \
                ACTION_PULSE_OPACITY_END)
        _start_child_annotator(jump_pulse_annotator)
    
    if is_instance_valid(jump_pulse_annotator):
        jump_pulse_annotator.pulse_position = \
                mobile_control_input.jump_pointer_current_position
    
    if Input.is_action_just_released("jump"):
        if is_instance_valid(jump_pulse_annotator):
            jump_pulse_annotator.emit_signal("finished")
    
    if Input.is_action_just_pressed("move_left") and \
            !mobile_control_input.recent_gesture_positions.empty():
        var move_left_trigger_annotator := TriggerAnnotator.new( \
                mobile_control_input.recent_gesture_positions.front() \
                        .position, \
                Time.elapsed_play_time_actual_sec, \
                ACTION_TRIGGER_DURATION_SEC, \
                MOVE_LEFT_DIRECTION_ANGLE, \
                ACTION_TRIGGER_RADIUS_START_PIXELS, \
                ACTION_TRIGGER_RADIUS_END_PIXELS, \
                Constants.MOVE_LEFT_COLOR, \
                ACTION_TRIGGER_OPACITY_START, \
                ACTION_TRIGGER_OPACITY_END, \
                ACTION_TRIGGER_EASING)
        _start_child_annotator(move_left_trigger_annotator)
        
        if !is_instance_valid(move_sideways_pulse_annotator):
            move_sideways_pulse_annotator = PulseAnnotator.new( \
                    mobile_control_input.latest_gesture_position, \
                    Time.elapsed_play_time_actual_sec, \
                    ACTION_PULSE_PERIOD_SEC, \
                    MOVE_LEFT_DIRECTION_ANGLE, \
                    ACTION_PULSE_RADIUS_START_PIXELS, \
                    ACTION_PULSE_RADIUS_END_PIXELS, \
                    Constants.MOVE_LEFT_COLOR, \
                    ACTION_PULSE_OPACITY_START, \
                    ACTION_PULSE_OPACITY_END)
            _start_child_annotator(move_sideways_pulse_annotator)
            
            if mobile_control_input \
                    .get_pointer_down_position_to_annotate() != Vector2.INF:
                move_sideways_pointer_down_position_pulse_annotator = \
                        PulseAnnotator.new( \
                                mobile_control_input \
                                        .get_pointer_down_position_to_annotate(), \
                                Time.elapsed_play_time_actual_sec, \
                                POINTER_DOWN_POSITION_PULSE_PERIOD_SEC, \
                                UNKNOWN_DIRECTION_ANGLE, \
                                POINTER_DOWN_POSITION_PULSE_RADIUS_START_PIXELS, \
                                POINTER_DOWN_POSITION_PULSE_RADIUS_END_PIXELS, \
                                Constants.UNKNOWN_COLOR, \
                                POINTER_DOWN_POSITION_PULSE_OPACITY_START, \
                                POINTER_DOWN_POSITION_PULSE_OPACITY_END)
                _start_child_annotator( \
                        move_sideways_pointer_down_position_pulse_annotator)
        else:
            move_sideways_pulse_annotator.direction_angle = \
                    MOVE_LEFT_DIRECTION_ANGLE
            move_sideways_pulse_annotator.base_color = \
                    Constants.MOVE_LEFT_COLOR
    
    if Input.is_action_just_pressed("move_right") and \
            !mobile_control_input.recent_gesture_positions.empty():
        var move_right_trigger_annotator := TriggerAnnotator.new( \
                mobile_control_input.recent_gesture_positions.front() \
                        .position, \
                Time.elapsed_play_time_actual_sec, \
                ACTION_TRIGGER_DURATION_SEC, \
                MOVE_RIGHT_DIRECTION_ANGLE, \
                ACTION_TRIGGER_RADIUS_START_PIXELS, \
                ACTION_TRIGGER_RADIUS_END_PIXELS, \
                Constants.MOVE_RIGHT_COLOR, \
                ACTION_TRIGGER_OPACITY_START, \
                ACTION_TRIGGER_OPACITY_END, \
                ACTION_TRIGGER_EASING)
        _start_child_annotator(move_right_trigger_annotator)
        
        if !is_instance_valid(move_sideways_pulse_annotator):
            move_sideways_pulse_annotator = PulseAnnotator.new( \
                    mobile_control_input.latest_gesture_position, \
                    Time.elapsed_play_time_actual_sec, \
                    ACTION_PULSE_PERIOD_SEC, \
                    MOVE_RIGHT_DIRECTION_ANGLE, \
                    ACTION_PULSE_RADIUS_START_PIXELS, \
                    ACTION_PULSE_RADIUS_END_PIXELS, \
                    Constants.MOVE_RIGHT_COLOR, \
                    ACTION_PULSE_OPACITY_START, \
                    ACTION_PULSE_OPACITY_END)
            _start_child_annotator(move_sideways_pulse_annotator)
            
            if mobile_control_input \
                    .get_pointer_down_position_to_annotate() != Vector2.INF:
                move_sideways_pointer_down_position_pulse_annotator = \
                        PulseAnnotator.new( \
                                mobile_control_input \
                                        .get_pointer_down_position_to_annotate(), \
                                Time.elapsed_play_time_actual_sec, \
                                POINTER_DOWN_POSITION_PULSE_PERIOD_SEC, \
                                UNKNOWN_DIRECTION_ANGLE, \
                                POINTER_DOWN_POSITION_PULSE_RADIUS_START_PIXELS, \
                                POINTER_DOWN_POSITION_PULSE_RADIUS_END_PIXELS, \
                                Constants.UNKNOWN_COLOR, \
                                POINTER_DOWN_POSITION_PULSE_OPACITY_START, \
                                POINTER_DOWN_POSITION_PULSE_OPACITY_END)
                _start_child_annotator( \
                        move_sideways_pointer_down_position_pulse_annotator)
        else:
            move_sideways_pulse_annotator.direction_angle = \
                    MOVE_RIGHT_DIRECTION_ANGLE
            move_sideways_pulse_annotator.base_color = \
                    Constants.MOVE_RIGHT_COLOR
    
    if is_instance_valid(move_sideways_pulse_annotator):
        move_sideways_pulse_annotator.pulse_position = \
                mobile_control_input.latest_gesture_position
    
    if (Input.is_action_just_released("move_left") or \
            Input.is_action_just_released("move_right")) and \
            !Input.is_action_just_pressed("move_left") and \
            !Input.is_action_just_pressed("move_right"):
        if is_instance_valid(move_sideways_pulse_annotator):
            move_sideways_pulse_annotator.emit_signal("finished")
        if is_instance_valid(move_sideways_pointer_down_position_pulse_annotator):
            move_sideways_pointer_down_position_pulse_annotator \
                    .emit_signal("finished")
    
    if mobile_control_input.is_positions_buffer_dirty:
        mobile_control_input.is_positions_buffer_dirty = false
        
        if mobile_control_input.recent_gesture_positions.empty():
            # Destroy finished gesture annotator.
            if is_instance_valid(gesture_annotator):
                gesture_annotator.queue_free()
                gesture_annotator = null
        
        elif !is_instance_valid(gesture_annotator):
            # Create new gesture annotator.
            gesture_annotator = GestureAnnotator.new(mobile_control_input)
            add_child(gesture_annotator)

func _start_child_annotator(annotator: Annotator) -> void:
    add_child(annotator)
    annotator.connect( \
            "finished", \
            self, \
            "_destroy_child_annotator", \
            [annotator])

func _destroy_child_annotator(annotator: Annotator) -> void:
    annotator.queue_free()
