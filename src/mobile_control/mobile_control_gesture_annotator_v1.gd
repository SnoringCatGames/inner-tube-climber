extends MobileControlGestureAnnotator
class_name MobileControlGestureAnnotatorV1

const GESTURE_POSITION_DURATION_SEC := 1.0

var JUMP_COLOR := Color.from_hsv(0.45, 1.0, 0.9, 1.0)
var MOVE_LEFT_COLOR := Color.from_hsv(0.117, 1.0, 0.9, 1.0)
var MOVE_RIGHT_COLOR := Color.from_hsv(0.783, 1.0, 0.9, 1.0)
var UNKNOWN_COLOR := Color.from_hsv(0.0, 0.0, 0.8, 1.0)

const JUMP_DIRECTION_ANGLE := -PI / 2.0
const MOVE_LEFT_DIRECTION_ANGLE := PI
const MOVE_RIGHT_DIRECTION_ANGLE := 0.0
const UNKNOWN_DIRECTION_ANGLE := INF

const ACTION_TRIGGER_RADIUS_START_INCHES := 0.25
var ACTION_TRIGGER_RADIUS_START_PIXELS := \
        ACTION_TRIGGER_RADIUS_START_INCHES * Utils.get_viewport_ppi()
const ACTION_TRIGGER_RADIUS_END_INCHES := 1.1
var ACTION_TRIGGER_RADIUS_END_PIXELS := \
        ACTION_TRIGGER_RADIUS_END_INCHES * Utils.get_viewport_ppi()
const ACTION_TRIGGER_DURATION_SEC := 0.33
const ACTION_TRIGGER_OPACITY_START := 0.8
const ACTION_TRIGGER_OPACITY_END := 0.0
const ACTION_TRIGGER_EASING := "ease_out"

const ACTION_PULSE_RADIUS_START_INCHES := 0.25 
var ACTION_PULSE_RADIUS_START_PIXELS := \
        ACTION_PULSE_RADIUS_START_INCHES * Utils.get_viewport_ppi()
const ACTION_PULSE_RADIUS_END_INCHES := 0.5
var ACTION_PULSE_RADIUS_END_PIXELS := \
        ACTION_PULSE_RADIUS_END_INCHES * Utils.get_viewport_ppi()
const ACTION_PULSE_PERIOD_SEC := 0.5
const ACTION_PULSE_OPACITY_START := 0.8
const ACTION_PULSE_OPACITY_END := 0.2






# Array<PositionTimeAndAction>
var gesture_buffer := []

var jump_pulse_annotator: PulseAnnotator

func _init(mobile_control_input: MobileControlInput).( \
        mobile_control_input) -> void:
    pass

# FIXME: ----------------------------
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
    var current_time := Time.elapsed_play_time_sec
    
    # Remove any stale positions.
    var oldest_rendered_gesture_time := \
            current_time - GESTURE_POSITION_DURATION_SEC
    while !gesture_buffer.empty() and \
            gesture_buffer.back().time_sec < oldest_rendered_gesture_time:
        gesture_buffer.pop_back()
    
    # Add any new positions.
    var previous_latest_time_sec: float = \
            gesture_buffer.front().time_sec if \
            !gesture_buffer.empty() else \
            -INF
    for position in mobile_control_input.recent_gesture_positions:
        if position.time_sec > previous_latest_time_sec:
            var position_time_and_action := PositionTimeAndAction.new( \
                    position.position, \
                    position.time_sec, \
                    "UNKNOWN")
            gesture_buffer.push_front(position_time_and_action)
        else:
            break
    
    # Update any previous UNKNOWN-type positions.
    var new_action := \
        "move_left" if \
        Input.is_action_just_pressed("move_left") else \
        ("move_right" if \
        Input.is_action_just_pressed("move_right") else \
        "unknown")
    if new_action != "unknown":
        var oldest_time_for_new_action := \
                current_time - \
                MobileControlInput \
                        .GESTURE_RECENT_POSITIONS_BUFFER_DELAY_SEC
        for position in gesture_buffer:
            if position.action == "unknown" and \
                    position.time_sec >= oldest_time_for_new_action:
                position.action = new_action
            else:
                break
    
    
    
    if Input.is_action_just_pressed("jump"):
        var jump_trigger_annotator := TriggerAnnotator.new( \
                mobile_control_input.jump_pointer_position, \
                current_time, \
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
                current_time, \
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
                current_time, \
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
                current_time, \
                ACTION_TRIGGER_DURATION_SEC, \
                MOVE_RIGHT_DIRECTION_ANGLE, \
                ACTION_TRIGGER_RADIUS_START_PIXELS, \
                ACTION_TRIGGER_RADIUS_END_PIXELS, \
                MOVE_RIGHT_COLOR, \
                ACTION_TRIGGER_OPACITY_START, \
                ACTION_TRIGGER_OPACITY_END, \
                ACTION_TRIGGER_EASING)
        _start_child_annotator(move_right_trigger_annotator)
    
    
    
    
    
    
    
    if mobile_control_input.is_positions_buffer_dirty or \
            Input.is_action_just_pressed("jump") or \
            Input.is_action_just_released("jump") or \
            Input.is_action_just_pressed("move_left") or \
            Input.is_action_just_released("move_left") or \
            Input.is_action_just_pressed("move_right") or \
            Input.is_action_just_released("move_right"):
        mobile_control_input.is_positions_buffer_dirty = false
        update()
        # FIXME: ----------------------------
        Global.debug_panel.add_message("update: curr=%4.2f; " % [
            current_time,
        ])

# FIXME: ----------------
# - Show an initial quick/short animation when action starts of the circle
#   enlarging and fading.
# - For the entire duration of the action being active, show a pulsing
#   series of animations with the circle more slowly enlarging and fading
#   and with a smaller diameter.

func _draw() -> void:
    # FIXME: ---------------
    Global.debug_panel.add_message("_draw")
    
    var current_time := Time.elapsed_play_time_sec
    
    var progress: float
    var opacity: float
    var color: Color
    var radius: float
    
    # Render gesture pulse.
    for position in range(gesture_buffer.size()):
        # FIXME: ----------- This should be based off of a module of the current time.
        pass

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

class PositionTimeAndAction extends PositionAndTime:
    var action: String
    
    func _init( \
            position: Vector2, \
            time_sec: float, \
            action: String).( \
            position, \
            time_sec) -> void:
        self.action = action
