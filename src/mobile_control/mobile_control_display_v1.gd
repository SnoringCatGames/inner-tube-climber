extends MobileControlDisplay
class_name MobileControlDisplayV1

const JUMP_INDICATOR_TEXTURE := \
        preload("res://assets/images/signs/tap_indicator.png")
const MOVE_SIDEWAYS_INDICATOR_TEXTURE := \
        preload("res://assets/images/signs/swipe_sideways_indicator.png")

var mobile_control_input: MobileControlInput

var jump_indicator: Sprite
var move_sideways_indicator: Sprite

func _init(mobile_control_input: MobileControlInput) -> void:
    self.mobile_control_input = mobile_control_input

func _enter_tree() -> void:
    jump_indicator = Sprite.new()
    jump_indicator.texture = JUMP_INDICATOR_TEXTURE
    jump_indicator.z_index = 1
    jump_indicator.modulate.a = OPACITY_UNPRESSED
    add_child(jump_indicator)
    
    move_sideways_indicator = Sprite.new()
    move_sideways_indicator.texture = MOVE_SIDEWAYS_INDICATOR_TEXTURE
    move_sideways_indicator.z_index = 1
    move_sideways_indicator.modulate.a = OPACITY_UNPRESSED
    add_child(move_sideways_indicator)
    
    Global.connect( \
            "display_resized", \
            self, \
            "_on_display_resized")
    _on_display_resized()

func _on_display_resized() -> void:
    var viewport_size := get_viewport().size
    var left_offset := PAD_OFFSET
    left_offset.y = max(left_offset.y, Utils.get_safe_area_margin_bottom())
    left_offset.x = max(left_offset.x, Utils.get_safe_area_margin_left())
    var right_offset := PAD_OFFSET
    right_offset.y = max(right_offset.y, Utils.get_safe_area_margin_bottom())
    right_offset.x = max(right_offset.x, Utils.get_safe_area_margin_right())
    var left_pad_position := Vector2( \
            left_offset.x, \
            viewport_size.y - left_offset.y)
    var right_pad_position := Vector2( \
            viewport_size.x - right_offset.x, \
            viewport_size.y - right_offset.y)
    
    jump_indicator.position = left_pad_position
    move_sideways_indicator.position = right_pad_position

func _process(_delta_sec: float) -> void:
    jump_indicator.modulate.a = \
            OPACITY_PRESSED if \
            mobile_control_input.is_jump_pressed else \
            OPACITY_UNPRESSED
    move_sideways_indicator.modulate.a = \
            OPACITY_PRESSED if \
            mobile_control_input.is_move_left_pressed or \
                    mobile_control_input.is_move_right_pressed else \
            OPACITY_UNPRESSED
