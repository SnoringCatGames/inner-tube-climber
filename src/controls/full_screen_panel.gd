tool
extends PanelContainer
class_name FullScreenPanel

func _init() -> void:
    add_font_override("font", Constants.MAIN_FONT_NORMAL)

func _enter_tree() -> void:
    if Engine.editor_hint:
        rect_size = Vector2(480, 480)
    else:
        Global.connect( \
                "display_resized", \
                self, \
                "_handle_display_resized")
        _handle_display_resized()

func _handle_display_resized() -> void:
    rect_size = get_viewport().size
