extends MobileControlGestureAnnotator
class_name MobileControlGestureAnnotatorV1

const GESTURE_POSITION_DURATION_SEC := 1.0

var JUMP_COLOR := Color.from_hsv(0.45, 1.0, 1.0, 1.0)
var MOVE_LEFT_COLOR := Color.from_hsv(0.117, 1.0, 1.0, 1.0)
var MOVE_RIGHT_COLOR := Color.from_hsv(0.783, 1.0, 1.0, 1.0)

const ACTION_TRIGGER_RADIUS_START_INCHES := 0.25
var ACTION_TRIGGER_RADIUS_START_PIXELS := \
        ACTION_TRIGGER_RADIUS_START_INCHES * Utils.get_viewport_ppi()
const ACTION_TRIGGER_RADIUS_END_INCHES := 0.75
var ACTION_TRIGGER_RADIUS_END_PIXELS := \
        ACTION_TRIGGER_RADIUS_END_INCHES * Utils.get_viewport_ppi()
const ACTION_TRIGGER_DURATION_SEC := 0.3
const ACTION_TRIGGER_OPACITY_START := 0.8
const ACTION_TRIGGER_OPACITY_END := 0.0
const ACTION_TRIGGER_EASING := "ease_out"

const ACTION_PULSE_RADIUS_START_INCHES := 0.3 
var ACTION_PULSE_RADIUS_START_PIXELS := \
        ACTION_PULSE_RADIUS_START_INCHES * Utils.get_viewport_ppi()
const ACTION_PULSE_RADIUS_END_INCHES := 0.6
var ACTION_PULSE_RADIUS_END_PIXELS := \
        ACTION_PULSE_RADIUS_END_INCHES * Utils.get_viewport_ppi()
const ACTION_PULSE_PERIOD_SEC := 0.5
const ACTION_PULSE_OPACITY_START := 0.8
const ACTION_PULSE_OPACITY_END := 0.0
const ACTION_PULSE_EASING := "ease_in_out"

func _init(mobile_control_input: MobileControlInput).( \
        mobile_control_input) -> void:
    pass

func _ready() -> void:
    if Global.is_debug_panel_shown:
        Global.debug_panel.add_message("")
        Global.debug_panel.add_message("")
        Global.debug_panel.add_message("")
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
    if mobile_control_input.is_positions_buffer_dirty or \
            Input.is_action_just_pressed("jump") or \
            Input.is_action_just_released("jump") or \
            Input.is_action_just_pressed("move_left") or \
            Input.is_action_just_released("move_left") or \
            Input.is_action_just_pressed("move_right") or \
            Input.is_action_just_released("move_right"):
        mobile_control_input.is_positions_buffer_dirty = false
        update()
    
    # FIXME: ----------------
    # - 2160 × 1080 (2:1) (-> 1080 x 540) (960 x 480 ??)
    # - Render a circle outline with a upward chevron through the middle for
    #   jump.
    # - Similar for move-sideways.
    # - Show an initial quick/short animation when action starts of the circle
    #   enlarging and fading.
    # - For the entire duration of the action being active, show a pulsing
    #   series of animations with the circle more slowly enlarging and fading
    #   and with a smaller diameter.
    # 
    # mobile_control_input.recent_gesture_positions
    # mobile_control_input.is_jump_pressed
    # mobile_control_input.is_move_left_pressed
    # mobile_control_input.is_move_right_pressed
    # mobile_control_input.jump_pointer_position
    # Input.is_action_just_pressed("jump")
    # Input.is_action_just_pressed("move_left")
    # Input.is_action_just_pressed("move_right")
    # Time.elapsed_play_time_sec

func _draw() -> void:
    if mobile_control_input.is_jump_pressed:
        draw_circle( \
                mobile_control_input.jump_pointer_position, \
                ACTION_TRIGGER_RADIUS_END_PIXELS, \
                JUMP_COLOR)
    
#    var move_sideways_
#    for position in recent_gesture_positions:
#        draw_circle( \
#                mobile_control_input.jump_pointer_position, \
#                ACTION_TRIGGER_RADIUS_START_INCHES, \
#                JUMP_COLOR)
