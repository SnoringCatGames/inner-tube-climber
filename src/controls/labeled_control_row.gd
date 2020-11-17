tool
extends HBoxContainer
class_name LabeledControlRow

export var label: String setget _set_label,_get_label

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
    _label_node.size_flags_vertical = Control.SIZE_FILL
    add_child(_label_node)
    
    _init_children()

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
                "Must define only one child node"
        update_configuration_warning()
        return
    
    var projected_control: Node = children[1]
    if !(projected_control is Control):
        configuration_warning = "Child node must be of type 'Control'."
        update_configuration_warning()
        return
    
    configuration_warning = ""
    update_configuration_warning()
    
    move_child(_label_node, 0)

func _get_configuration_warning() -> String:
    return configuration_warning

func _set_label(value: String) -> void:
    label = value
    if _label_node != null:
        _label_node.text = value

func _get_label() -> String:
    return label
