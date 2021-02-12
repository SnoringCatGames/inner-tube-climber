extends Node2D
class_name MobileControlUI

var version := -1
var mobile_control_display: MobileControlDisplay
var mobile_control_input: MobileControlInput
var mobile_control_gesture_annotator: MobileControlGestureAnnotator

func _init(version: int) -> void:
    self.version = version

func _enter_tree() -> void:
    match version:
        1:
            mobile_control_input = MobileControlInputV1.new()
            mobile_control_display = \
                    MobileControlDisplayV1.new(mobile_control_input)
        2:
            mobile_control_input = MobileControlInputV2.new()
            mobile_control_display = \
                    MobileControlDisplayV2.new(mobile_control_input)
        3:
            mobile_control_input = MobileControlInputV3.new()
            mobile_control_display = \
                    MobileControlDisplayV1.new(mobile_control_input)
        _:
            Utils.error()
    
    mobile_control_gesture_annotator = \
            MobileControlGestureAnnotator.new(mobile_control_input)
    
    add_child(mobile_control_display)
    add_child(mobile_control_input)
    add_child(mobile_control_gesture_annotator)
    
    mobile_control_display.visible = Global.are_mobile_controls_shown

func destroy() -> void:
    if mobile_control_display != null:
        mobile_control_display.queue_free()
    if mobile_control_input != null:
        mobile_control_input.destroy()
        mobile_control_input.queue_free()
    if mobile_control_gesture_annotator != null:
        mobile_control_gesture_annotator.queue_free()

func update_displays() -> void:
    mobile_control_display.visible = Global.are_mobile_controls_shown
