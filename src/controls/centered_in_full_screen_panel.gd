tool
extends PanelContainer
class_name CenteredInFullScreenPanel

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
    
    var game_area_region: Rect2 = Global.get_game_area_region()
    var viewport_size := get_viewport().size
    $CenterPanel.rect_position = (viewport_size - game_area_region.size) * 0.5
    $CenterPanel.rect_size = game_area_region.size