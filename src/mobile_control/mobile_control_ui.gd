extends Node2D
class_name MobileControlUI

var version := -1
var mobile_control_display: MobileControlDisplay
var mobile_control_input: MobileControlInput

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
        3:
            mobile_control_display = MobileControlDisplayV2.new()
            mobile_control_input = MobileControlInputV3.new()
        _:
            Utils.error()
    
    add_child(mobile_control_display)
    add_child(mobile_control_input)

func destroy() -> void:
    if mobile_control_display != null:
        remove_child(mobile_control_display)
        mobile_control_display.queue_free()
    if mobile_control_input != null:
        remove_child(mobile_control_input)
        mobile_control_input.queue_free()
