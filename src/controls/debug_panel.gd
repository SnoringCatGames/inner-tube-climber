extends Node2D
class_name DebugPanel

var is_ready := false
var text := ""

func _ready() -> void:
    is_ready = true
    $PanelContainer/ScrollContainer/Label.text = text
    Time.set_timeout(funcref(self, "_scroll_to_bottom"), 0.2)

func add_message(message: String) -> void:
    text += "> " + message + "\n"
    if is_ready:
        $PanelContainer/ScrollContainer/Label.text = text
        Time.set_timeout(funcref(self, "_scroll_to_bottom"), 0.2)

func _scroll_to_bottom() -> void:
    $PanelContainer/ScrollContainer.scroll_vertical = \
            $PanelContainer/ScrollContainer.get_v_scrollbar().max_value
