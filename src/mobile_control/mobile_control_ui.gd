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
            mobile_control_display = MobileControlDisplayV1.new()
            mobile_control_input = MobileControlInputV1.new()
        2:
            mobile_control_display = MobileControlDisplayV2.new()
            mobile_control_input = MobileControlInputV2.new()
        _:
            Utils.error()
    
    mobile_control_gesture_annotator = \
            MobileControlGestureAnnotator.new(mobile_control_input)
    
    add_child(mobile_control_display)
    add_child(mobile_control_input)
    add_child(mobile_control_gesture_annotator)

func destroy() -> void:
    if mobile_control_display != null:
        remove_child(mobile_control_display)
        mobile_control_display.queue_free()
    if mobile_control_input != null:
        remove_child(mobile_control_input)
        mobile_control_input.queue_free()
    if mobile_control_gesture_annotator != null:
        remove_child(mobile_control_gesture_annotator)
        mobile_control_gesture_annotator.queue_free()
