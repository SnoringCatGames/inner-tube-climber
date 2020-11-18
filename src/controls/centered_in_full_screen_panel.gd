tool
extends PanelContainer
class_name CenteredInFullScreenPanel

var configuration_warning := ""

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

func _ready() -> void:
    var children := get_children()
    if children.size() > 2:
        configuration_warning = "Must define only one child node."
        update_configuration_warning()
        return
    if children.size() < 2:
        configuration_warning = "Must define a child node."
        update_configuration_warning()
        return
    assert(children[0] == $CenterPanelOuter)
    
    if Engine.is_editor_hint():
        return
    
    var projected_content: Control = children[1]
    remove_child(projected_content)
    $CenterPanelOuter/CenterPanelInner.add_child(projected_content)

func _handle_display_resized() -> void:
    rect_size = get_viewport().size
    
    var game_area_region: Rect2 = Global.get_game_area_region()
    var viewport_size := get_viewport().size
    $CenterPanelOuter.rect_position = \
            (viewport_size - game_area_region.size) * 0.5
    $CenterPanelOuter.rect_size = game_area_region.size

func _get_configuration_warning() -> String:
    return configuration_warning
