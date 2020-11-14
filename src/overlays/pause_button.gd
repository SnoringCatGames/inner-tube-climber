extends Node2D
class_name PauseButton

const OPACITY_UNPRESSED := 1.0
const OPACITY_PRESSED := 0.6
const PAUSE_BUTTON_TOP_RIGHT_OFFSET := Vector2(32.0, 32.0)

func _enter_tree() -> void:
    modulate.a = OPACITY_UNPRESSED
    Global.connect( \
            "display_resized", \
            self, \
            "_on_display_resized")
    _on_display_resized()

func _on_display_resized() -> void:
    var viewport_size := get_viewport().size
    var offset := PAUSE_BUTTON_TOP_RIGHT_OFFSET
    offset.y = max(offset.y, Utils.get_safe_area_margin_top())
    offset.x = max(offset.x, Utils.get_safe_area_margin_right())
    position = Vector2( \
            viewport_size.x - offset.x, \
            offset.y)

func _notification(notification: int) -> void:
    if notification == MainLoop.NOTIFICATION_WM_FOCUS_OUT and \
            Nav.get_active_screen_type() == ScreenType.GAME:
        _pause()

func _on_TextureButton_pressed():
    _pause()

func _on_TextureButton_button_down():
    modulate.a = OPACITY_PRESSED

func _on_TextureButton_button_up():
    modulate.a = OPACITY_UNPRESSED

func _pause() -> void:
    Nav.set_screen_is_open( \
            ScreenType.PAUSE, \
            true)
