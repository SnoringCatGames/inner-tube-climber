extends MobileControlGestureAnnotator
class_name MobileControlGestureAnnotatorV1

var jump_pulse_annotator: PulseAnnotator
var gesture_annotator: GestureAnnotator

func _init(mobile_control_input: MobileControlInput).( \
        mobile_control_input) -> void:
    pass

func _ready() -> void:
    if Global.is_debug_panel_shown:
        Global.debug_panel.add_message((
                    "in=%s; " + \
                    "px=%s; " + \
                    "ppi=%s; " + \
                    "vwprt=(%4d, %4d); " + \
                    "scale=%s;" + \
                    "scsiz=%s;" + \
                    "wnsiz=%s;" + \
                    ""
                ) % [
                    ACTION_TRIGGER_RADIUS_END_INCHES,
                    ACTION_TRIGGER_RADIUS_END_PIXELS,
                    Utils.get_viewport_ppi(),
                    get_viewport().size.x,
                    get_viewport().size.y,
                    OS.get_screen_scale(),
                    OS.get_screen_size(),
                    OS.get_real_window_size(),
                ])

func _process(delta_sec: float) -> void:
    if Input.is_action_just_pressed("jump"):
        var jump_trigger_annotator := TriggerAnnotator.new( \
                mobile_control_input.jump_pointer_position, \
                Time.elapsed_play_time_sec, \
                ACTION_TRIGGER_DURATION_SEC, \
                JUMP_DIRECTION_ANGLE, \
                ACTION_TRIGGER_RADIUS_START_PIXELS, \
                ACTION_TRIGGER_RADIUS_END_PIXELS, \
                JUMP_COLOR, \
                ACTION_TRIGGER_OPACITY_START, \
                ACTION_TRIGGER_OPACITY_END, \
                ACTION_TRIGGER_EASING)
        _start_child_annotator(jump_trigger_annotator)
        
        if jump_pulse_annotator != null:
            jump_pulse_annotator.emit_signal("finished")
        jump_pulse_annotator = PulseAnnotator.new( \
                mobile_control_input.jump_pointer_position, \
                Time.elapsed_play_time_sec, \
                ACTION_PULSE_PERIOD_SEC, \
                JUMP_DIRECTION_ANGLE, \
                ACTION_PULSE_RADIUS_START_PIXELS, \
                ACTION_PULSE_RADIUS_END_PIXELS, \
                JUMP_COLOR, \
                ACTION_PULSE_OPACITY_START, \
                ACTION_PULSE_OPACITY_END)
        _start_child_annotator(jump_pulse_annotator)
    
    if Input.is_action_just_released("jump"):
        if jump_pulse_annotator != null:
            jump_pulse_annotator.emit_signal("finished")
    
    if Input.is_action_just_pressed("move_left"):
        var move_left_trigger_annotator := TriggerAnnotator.new( \
                mobile_control_input.recent_gesture_positions.front() \
                        .position, \
                Time.elapsed_play_time_sec, \
                ACTION_TRIGGER_DURATION_SEC, \
                MOVE_LEFT_DIRECTION_ANGLE, \
                ACTION_TRIGGER_RADIUS_START_PIXELS, \
                ACTION_TRIGGER_RADIUS_END_PIXELS, \
                MOVE_LEFT_COLOR, \
                ACTION_TRIGGER_OPACITY_START, \
                ACTION_TRIGGER_OPACITY_END, \
                ACTION_TRIGGER_EASING)
        _start_child_annotator(move_left_trigger_annotator)
    
    if Input.is_action_just_pressed("move_right"):
        var move_right_trigger_annotator := TriggerAnnotator.new( \
                mobile_control_input.recent_gesture_positions.front() \
                        .position, \
                Time.elapsed_play_time_sec, \
                ACTION_TRIGGER_DURATION_SEC, \
                MOVE_RIGHT_DIRECTION_ANGLE, \
                ACTION_TRIGGER_RADIUS_START_PIXELS, \
                ACTION_TRIGGER_RADIUS_END_PIXELS, \
                MOVE_RIGHT_COLOR, \
                ACTION_TRIGGER_OPACITY_START, \
                ACTION_TRIGGER_OPACITY_END, \
                ACTION_TRIGGER_EASING)
        _start_child_annotator(move_right_trigger_annotator)
    
    if mobile_control_input.is_positions_buffer_dirty:
        mobile_control_input.is_positions_buffer_dirty = false
        
        if mobile_control_input.recent_gesture_positions.empty():
            # Destroy finished gesture annotator.
            if gesture_annotator != null:
                remove_child(gesture_annotator)
                gesture_annotator.queue_free()
                gesture_annotator = null
        
        elif gesture_annotator == null:
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
    remove_child(annotator)
    annotator.queue_free()
