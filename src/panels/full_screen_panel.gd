tool
extends PanelContainer
class_name FullScreenPanel

func _init() -> void:
    rect_size = Vector2(20000, 20000)

func _enter_tree() -> void:
    Global.connect( \
            "display_resized", \
            self, \
            "_handle_display_resized")
    _handle_display_resized()

func _handle_display_resized() -> void:
    rect_size = get_viewport().size
