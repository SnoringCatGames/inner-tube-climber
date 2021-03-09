extends Node2D
class_name MobileControlUI

var version := ""
var mobile_control_display: MobileControlDisplay
var mobile_control_input: MobileControlInput
var mobile_control_gesture_annotator: MobileControlGestureAnnotator

func _init(version: String) -> void:
    self.version = version

func _enter_tree() -> void:
    var is_jump_on_left_side := version.ends_with("R")
    match version:
        "1R","1L":
            mobile_control_input = MobileControlInputV1.new( \
                    is_jump_on_left_side)
            mobile_control_display = MobileControlDisplayV1.new( \
                    mobile_control_input, \
                    is_jump_on_left_side)
        "2R","2L":
            mobile_control_input = MobileControlInputV2.new( \
                    is_jump_on_left_side)
            mobile_control_display = MobileControlDisplayV1.new( \
                    mobile_control_input, \
                    is_jump_on_left_side)
        "3R","3L":
            mobile_control_input = MobileControlInputV3.new( \
                    is_jump_on_left_side)
            mobile_control_display = MobileControlDisplayV1.new( \
                    mobile_control_input, \
                    is_jump_on_left_side)
        "4":
            mobile_control_input = MobileControlInputV4.new()
            mobile_control_display = \
                    MobileControlDisplayV2.new(mobile_control_input)
        _:
            Utils.error()
    
    mobile_control_gesture_annotator = \
            MobileControlGestureAnnotator.new(mobile_control_input)
    
    add_child(mobile_control_display)
    add_child(mobile_control_input)
    add_child(mobile_control_gesture_annotator)
    
    mobile_control_display.visible = Global.are_mobile_controls_shown

func destroy() -> void:
    if is_instance_valid(mobile_control_display):
        mobile_control_display.queue_free()
    if is_instance_valid(mobile_control_input):
        mobile_control_input.destroy()
        mobile_control_input.queue_free()
    if is_instance_valid(mobile_control_gesture_annotator):
        mobile_control_gesture_annotator.queue_free()

func update_displays() -> void:
    mobile_control_display.visible = Global.are_mobile_controls_shown
