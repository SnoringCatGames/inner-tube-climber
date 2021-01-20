tool
extends PanelContainer
class_name LabeledControlRow

const CHECKBOX_SIZE_DEFAULT := Vector2(16.0, 28.0)
const CHECKBOX_SCALE := Vector2(4.0, 4.0)

export var label: String setget _set_label,_get_label
export var padding := 8.0 setget _set_padding,_get_padding
export var is_odd_row := true setget _set_is_odd_row,_get_is_odd_row

var configuration_warning := ""

var _label_node: Label

func _ready() -> void:
    # For some reason, when running in-editor, there can be extra children
    # created.
    for child in get_children():
        if child is Label:
            remove_child(child)
            child.queue_free()
    
    _label_node = Label.new()
    _label_node.text = label
    _label_node.align = Label.ALIGN_LEFT
    _label_node.valign = Label.VALIGN_CENTER
    _label_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _label_node.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    add_child(_label_node)
    
    _init_children()
    _set_is_odd_row(is_odd_row)

func add_child(child: Node, legible_unique_name=false) -> void:
    .add_child(child, legible_unique_name)
    _init_children()

func remove_child(child: Node) -> void:
    .remove_child(child)
    _init_children()

func _init_children() -> void:
    var children := get_children()
    if children.size() != 2:
        configuration_warning = \
                "Must define a child node." if \
                children.size() < 2 else \
                "Must define only one child node."
        update_configuration_warning()
        return
    
    move_child(_label_node, 0)
    
    var projected_control: Node = children[1]
    projected_control.size_flags_horizontal = Control.SIZE_SHRINK_END
    projected_control.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    _label_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    if projected_control is CheckBox:
#        projected_control.size_flags_vertical = 0
        projected_control.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        projected_control.rect_scale = CHECKBOX_SCALE
        projected_control.rect_position.y = \
                padding + CHECKBOX_SIZE_DEFAULT.y - CHECKBOX_SCALE.y / 2.0
    
    if !(projected_control is Control):
        configuration_warning = "Child node must be of type 'Control'."
        update_configuration_warning()
        return
    
    configuration_warning = ""
    update_configuration_warning()
    
    call_deferred("_update_height")

func _update_height() -> void:
    var max_child_height := 0.0
    for child in get_children():
        max_child_height = max(max_child_height, child.rect_size.y)
    rect_min_size.y = max_child_height + padding * 2

func _get_configuration_warning() -> String:
    return configuration_warning

func _set_label(value: String) -> void:
    label = value
    if _label_node != null:
        _label_node.text = value

func _get_label() -> String:
    return label

func _set_padding(value: float) -> void:
    padding = value
    if _label_node != null:
        _init_children()

func _get_padding() -> float:
    return padding

func _set_is_odd_row(is_odd: bool) -> void:
    is_odd_row = is_odd
    var style: StyleBox
    if is_odd_row:
        style = StyleBoxEmpty.new()
    else:
        style = StyleBoxFlat.new()
        style.bg_color = Constants.KEY_VALUE_EVEN_ROW_COLOR
    add_stylebox_override("panel", style)

func _get_is_odd_row() -> bool:
    return is_odd_row
    
