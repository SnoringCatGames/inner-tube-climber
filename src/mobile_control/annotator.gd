extends Node2D
class_name Annotator

signal finished

const GESTURE_POSITION_DURATION_SEC := 0.7

const JUMP_DIRECTION_ANGLE := -PI / 2.0
const MOVE_LEFT_DIRECTION_ANGLE := PI
const MOVE_RIGHT_DIRECTION_ANGLE := 0.0
const UNKNOWN_DIRECTION_ANGLE := INF

const ACTION_TRIGGER_RADIUS_START_INCHES := 0.15
var ACTION_TRIGGER_RADIUS_START_PIXELS := \
        ACTION_TRIGGER_RADIUS_START_INCHES * Utils.get_viewport_ppi()
const ACTION_TRIGGER_RADIUS_END_INCHES := 0.8
var ACTION_TRIGGER_RADIUS_END_PIXELS := \
        ACTION_TRIGGER_RADIUS_END_INCHES * Utils.get_viewport_ppi()
const ACTION_TRIGGER_DURATION_SEC := 0.28
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

const ACTION_GESTURE_RADIUS_START_MULTIPLIER := 1.0
const ACTION_GESTURE_RADIUS_END_MULTIPLIER := 0.01
const ACTION_GESTURE_OPACITY_START_MULTIPLIER := 1.0
const ACTION_GESTURE_OPACITY_END_MULTIPLIER := 0.0
const ACTION_GESTURE_EASING := "ease_out_strong"

static func action_to_direction_angle(action: String) -> float:
    match action:
        "jump":
            return JUMP_DIRECTION_ANGLE
        "move_left":
            return MOVE_LEFT_DIRECTION_ANGLE
        "move_right":
            return MOVE_RIGHT_DIRECTION_ANGLE
        "unknown":
            return UNKNOWN_DIRECTION_ANGLE
        _:
            Utils.error()
            return INF
            

func action_to_color(action: String) -> Color:
    match action:
        "jump":
            return Constants.JUMP_COLOR
        "move_left":
            return Constants.MOVE_LEFT_COLOR
        "move_right":
            return Constants.MOVE_RIGHT_COLOR
        "unknown":
            return Constants.UNKNOWN_COLOR
        _:
            Utils.error()
            return Color.white
