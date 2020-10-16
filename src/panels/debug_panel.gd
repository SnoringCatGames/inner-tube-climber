extends PanelContainer
class_name DebugPanel

func add_message(message: String) -> void:
    $ScrollContainer/Label.text += "> " + message + "\n"
    Time.set_timeout(funcref(self, "_scroll_to_bottom"), 0.1)

func _scroll_to_bottom() -> void:
    $ScrollContainer.scroll_vertical = \
            $ScrollContainer.get_v_scrollbar().max_value
