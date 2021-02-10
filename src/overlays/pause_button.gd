extends Node2D
class_name PauseButton

const OPACITY_UNPRESSED := 1.0
const OPACITY_PRESSED := 0.6
const PAUSE_BUTTON_TOP_RIGHT_OFFSET := Vector2(36.0, 36.0)
const PAUSE_BUTTON_RADIUS := 24.0

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

func _pause() -> void:
    Nav.open(ScreenType.PAUSE)

func _on_TextureButton_gui_input(event: InputEvent) -> void:
    var is_mouse_down: bool = \
            event is InputEventMouseButton and \
            event.pressed
    var is_touch_down: bool = \
            (event is InputEventScreenTouch and \
                    event.pressed) or \
            event is InputEventScreenDrag
    
    var is_mouse_up: bool = \
            event is InputEventMouseButton and \
            !event.pressed
    var is_touch_up: bool = \
            (event is InputEventScreenTouch and \
                    !event.pressed)
    
    var is_mouse_event := is_mouse_down or is_mouse_up
    var is_touch_event := is_touch_down or is_touch_up
    var is_pointer_event := is_mouse_event or is_touch_event
    
    if is_mouse_event and \
            position.distance_squared_to(event.global_position) < \
                    PAUSE_BUTTON_RADIUS * PAUSE_BUTTON_RADIUS:
        if is_mouse_down or is_touch_down:
            $TextureButton.accept_event()
            modulate.a = OPACITY_PRESSED
        if is_mouse_up or is_touch_up:
            modulate.a = OPACITY_UNPRESSED
            _pause()
