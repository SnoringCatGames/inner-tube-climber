tool
extends VBoxContainer
class_name LabeledControlList



# FIXME: LEFT OFF HERE: -----------------------------------
# - Make CheckBoxes bigger:
#   - Add a wrapper control
#   - Set scale
#   - Set position
# - Add event handling for changes/interactions with controls.
#   - Listen for changes in the consumer class.
# - Move LabeledControlType enum out into a separate file.
# - Replace usages of KeyValueRow and LabeledControlRow with this.
# - And then delete those old classes.



# var label: String
# var type: LabeledControlType
#
# var text: String
#
# var pressed: bool
#
# var selected_index: int
# var options: Array<String>
var items := [] setget _set_items,_get_items

var row_height := 48.0 setget _set_row_height,_get_row_height

var _odd_row_style: StyleBoxEmpty
var _even_row_style: StyleBoxFlat

func _init() -> void:
    # FIXME: MOVE TO CONSUMER
    items = [
        {
            label = "text",
            type = TEXT,
            text = "foobar",
        },
        {
            label = "checkbox",
            type = CHECKBOX,
            pressed = true,
        },
        {
            label = "dropdown",
            type = DROPDOWN,
            selected_index = 1,
            options = [
                "a",
                "b",
                "c",
                "d",
            ],
        },
    ]
    
    _odd_row_style = StyleBoxEmpty.new()
    
    _even_row_style = StyleBoxFlat.new()
    _even_row_style.bg_color = Constants.KEY_VALUE_EVEN_ROW_COLOR

# FIXME: Remove?
func _ready() -> void:
    add_constant_override("separation", 0)
    
    _update_children()

func _update_children() -> void:
    for child in get_children():
        remove_child(child)
        child.queue_free()
    
    for index in range(items.size()):
        var item: Dictionary = items[index]
        
        var row := PanelContainer.new()
        add_child(row)
        
        var hbox := HBoxContainer.new()
        row.add_child(hbox)
        
        var label := Label.new()
        label.text = item.label
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        hbox.add_child(label)
        
        var control := _create_control(item)
        control.size_flags_horizontal = Control.SIZE_SHRINK_END
        control.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        hbox.add_child(control)
        
        hbox.rect_min_size.y = row_height
        hbox.add_constant_override("separation", 0)
        
        var style: StyleBox = \
                _odd_row_style if \
                index % 2 == 0 else \
                _even_row_style
        add_stylebox_override("panel", style)

func _create_control(item: Dictionary) -> Control:
    match item.type:
        TEXT:
            var label := Label.new()
            label.text = item.text
            return label
        CHECKBOX:
            var checkbox := CheckBox.new()
            checkbox.pressed = item.pressed
            return checkbox
        DROPDOWN:
            var dropdown := OptionButton.new()
            for option in item.options:
                dropdown.add_item(option)
            dropdown.select(item.selected_index)
            return dropdown
        _:
            Utils.error()
            return null

func _set_items(value: Array) -> void:
    items = value
    _update_children()

func _get_items() -> Array:
    return items

func _set_row_height(value: float) -> void:
    row_height = value
    _update_children()

func _get_row_height() -> float:
    return row_height

enum {
    TEXT,
    CHECKBOX,
    DROPDOWN,
}
