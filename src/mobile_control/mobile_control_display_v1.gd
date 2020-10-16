extends MobileControlDisplay
class_name MobileControlDisplayV1

const PAD_SIZE := Vector2( \
        80.0, \
        80.0)

var PAD_COLOR := Color.from_hsv( \
        0.6, \
        0.9, \
        0.9, \
        0.9)

var left_pad_region: Rect2
var right_pad_region: Rect2

func _enter_tree() -> void:
    Global.connect( \
            "display_resized", \
            self, \
            "_on_display_resized")
    _on_display_resized()

func _on_display_resized() -> void:
    var viewport_size := get_viewport().size
    var left_pad_position := Vector2( \
            0.0, \
            viewport_size.y - PAD_SIZE.y)
    var right_pad_position := Vector2( \
            viewport_size.x - PAD_SIZE.x, \
            viewport_size.y - PAD_SIZE.y)
    left_pad_region = Rect2( \
            left_pad_position, \
            PAD_SIZE)
    right_pad_region = Rect2( \
            right_pad_position, \
            PAD_SIZE)
    update()

func _draw() -> void:
    draw_rect(left_pad_region, PAD_COLOR)
    draw_rect(right_pad_region, PAD_COLOR)
