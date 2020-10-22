extends MobileControlDisplay
class_name MobileControlDisplayV2

const MOVE_ALL_WAYS_INDICATOR_TEXTURE := \
        preload("res://assets/images/signs/swipe_all_ways_indicator.png")

var mobile_control_input: MobileControlInput

var move_all_ways_indicator: Sprite

func _init(mobile_control_input: MobileControlInput) -> void:
    self.mobile_control_input = mobile_control_input

func _enter_tree() -> void:
    move_all_ways_indicator = Sprite.new()
    move_all_ways_indicator.texture = MOVE_ALL_WAYS_INDICATOR_TEXTURE
    move_all_ways_indicator.z_index = 1
    move_all_ways_indicator.modulate.a = OPACITY_UNPRESSED
    add_child(move_all_ways_indicator)
    
    Global.connect( \
            "display_resized", \
            self, \
            "_on_display_resized")
    _on_display_resized()

func _on_display_resized() -> void:
    var viewport_size := get_viewport().size
    var right_pad_position := Vector2( \
            viewport_size.x - PAD_OFFSET.x, \
            viewport_size.y - PAD_OFFSET .y)
    
    move_all_ways_indicator.position = right_pad_position

func _process(delta_sec: float) -> void:
    move_all_ways_indicator.modulate.a = \
            OPACITY_PRESSED if \
            mobile_control_input.is_jump_pressed or \
                    mobile_control_input.is_move_left_pressed or \
                    mobile_control_input.is_move_right_pressed else \
            OPACITY_UNPRESSED
