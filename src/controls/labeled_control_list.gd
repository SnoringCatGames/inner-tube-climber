tool
extends VBoxContainer
class_name LabeledControlList

signal control_changed(index)

const ABOUT_ICON_NORMAL := \
        preload("res://assets/images/icons/about-icon-normal.png")
const ABOUT_ICON_HOVER := \
        preload("res://assets/images/icons/about-icon-hover.png")
const ABOUT_ICON_ACTIVE := \
        preload("res://assets/images/icons/about-icon-active.png")

const ENABLED_ALPHA := 1.0
const DISABLED_ALPHA := 0.3

const CHECKBOX_SCALE := Vector2(2.0, 2.0)
const CHECKBOX_OFFSET := Vector2(-28.0, -31.0)
#const CHECKBOX_SCALE := Vector2(1.0, 1.0)
#const CHECKBOX_OFFSET := Vector2(0.0, 0.0)
#const CHECKBOX_SCALE := Vector2(3.0, 3.0)
#const CHECKBOX_OFFSET := Vector2(-48.0, -17.5)

# label: String
# type: LabeledControlType
#
# text: String
#
# pressed: bool
#
# selected_index: int
# options: Array<String>
#
# description: String
var items := [] setget _set_items,_get_items

export var row_height := 40.0 setget _set_row_height,_get_row_height
export var padding_horizontal := 8.0 setget \
        _set_padding_horizontal,_get_padding_horizontal

var _odd_row_style: StyleBoxEmpty
var _even_row_style: StyleBoxFlat

func _init() -> void:
    _odd_row_style = StyleBoxEmpty.new()
    
    _even_row_style = StyleBoxFlat.new()
    _even_row_style.bg_color = Constants.KEY_VALUE_EVEN_ROW_COLOR

func _ready() -> void:
    _update_children()

func _update_children() -> void:
    for child in get_children():
        child.queue_free()
    
    for index in range(items.size()):
        var item: Dictionary = items[index]
        
        var row := PanelContainer.new()
        var style: StyleBox = \
                _odd_row_style if \
                index % 2 == 0 else \
                _even_row_style
        row.add_stylebox_override("panel", style)
        add_child(row)
        
        var hbox := HBoxContainer.new()
        hbox.rect_min_size.y = row_height
        hbox.add_constant_override("separation", 0)
        row.add_child(hbox)
        
        var spacer1 := Control.new()
        spacer1.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        spacer1.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        spacer1.rect_min_size.x = padding_horizontal
        hbox.add_child(spacer1)
        
        var label := Label.new()
        label.text = item.label
        label.modulate.a = \
                DISABLED_ALPHA if \
                item.disabled else \
                ENABLED_ALPHA
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        hbox.add_child(label)
        
        if item.description != "":
            var description_button = TextureButton.new()
            description_button.texture_normal = ABOUT_ICON_NORMAL
            description_button.texture_hover = ABOUT_ICON_HOVER
            description_button.texture_pressed = ABOUT_ICON_ACTIVE
            description_button.connect( \
                    "pressed", \
                    self, \
                    "_on_description_button_pressed", \
                    [
                        item.label,
                        item.description
                    ])
            description_button.size_flags_horizontal = \
                    Control.SIZE_SHRINK_CENTER
            description_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
            hbox.add_child(description_button)
            
            var spacer3 := Control.new()
            spacer3.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
            spacer3.size_flags_vertical = Control.SIZE_SHRINK_CENTER
            spacer3.rect_min_size.x = padding_horizontal * 2.0
            hbox.add_child(spacer3)
        
        var control := _create_control(item, index, item.disabled)
        control.size_flags_horizontal = Control.SIZE_SHRINK_END
        control.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        hbox.add_child(control)
        
        var spacer2 := Control.new()
        spacer2.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        spacer2.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        spacer2.rect_min_size.x = padding_horizontal
        hbox.add_child(spacer2)
    
    Utils.set_mouse_filter_recursively( \
            self, \
            Control.MOUSE_FILTER_PASS)

func _create_control( \
        item: Dictionary, \
        index: int, \
        disabled: bool) -> Control:
    var alpha := \
            DISABLED_ALPHA if \
            disabled else \
            ENABLED_ALPHA
    match item.type:
        LabeledControlItemType.TEXT:
            var label := Label.new()
            label.text = item.text
            label.modulate.a = alpha
            item.control = label
            return label
        LabeledControlItemType.CHECKBOX:
            var checkbox := CheckBox.new()
            checkbox.pressed = item.pressed
            checkbox.disabled = disabled
            checkbox.modulate.a = alpha
            checkbox.size_flags_horizontal = 0
            checkbox.size_flags_vertical = 0
            checkbox.rect_position = CHECKBOX_OFFSET
            checkbox.rect_scale = CHECKBOX_SCALE
            checkbox.connect( \
                    "pressed", \
                    self, \
                    "_on_control_pressed", \
                    [index])
            checkbox.connect( \
                    "pressed", \
                    self, \
                    "_on_checkbox_pressed", \
                    [index])
            var wrapper := Control.new()
            wrapper.add_child(checkbox)
            item.control = checkbox
            return wrapper
        LabeledControlItemType.DROPDOWN:
            var dropdown := OptionButton.new()
            for option in item.options:
                dropdown.add_item(option)
            dropdown.select(item.selected_index)
            dropdown.disabled = disabled
            dropdown.connect( \
                    "pressed", \
                    self, \
                    "_on_control_pressed", \
                    [index])
            dropdown.connect( \
                    "item_selected", \
                    self, \
                    "_on_dropdown_item_selected", \
                    [index])
            item.control = dropdown
            return dropdown
        _:
            Utils.error()
            return null

func _on_control_pressed(_index: int) -> void:
    Global.give_button_press_feedback()

func _on_checkbox_pressed(checkbox_index: int) -> void:
    var item: Dictionary = items[checkbox_index]
    item.pressed = item.control.pressed
    emit_signal("control_changed", checkbox_index)

func _on_dropdown_item_selected( \
        _option_index: int, \
        dropdown_index: int) -> void:
    Global.give_button_press_feedback()
    var item: Dictionary = items[dropdown_index]
    item.selected_index = item.control.selected
    emit_signal("control_changed", dropdown_index)

func _on_description_button_pressed( \
        label: String, \
        description: String) -> void:
    Global.give_button_press_feedback()
    Nav.open( \
            ScreenType.NOTIFICATION, \
            false, \
            {
                header_text = label,
                is_back_button_shown = true,
                body_text = description,
                close_button_text = "OK",
                body_alignment = ALIGN_BEGIN,
            })

func find_index(label: String) -> int:
    for index in range(items.size()):
        if items[index].label == label:
            return index
    Utils.error()
    return -1

func find_item(label: String) -> Dictionary:
    return items[find_index(label)]

func _normalize_item(item: Dictionary) -> void:
    if !item.has("label") or \
            !item.has("type"):
        Utils.error()
    
    if !item.has("disabled"):
        item["disabled"] = false
    
    if !item.has("control"):
        item["control"] = null
    
    if !item.has("description"):
        item["description"] = ""
    
    match item.type:
        LabeledControlItemType.TEXT:
            if !item.has("text"):
                item["text"] = ""
        LabeledControlItemType.CHECKBOX:
            if !item.has("pressed"):
                item["pressed"] = false
        LabeledControlItemType.DROPDOWN:
            if !item.has("options"):
                item["options"] = []
            if !item.has("selected_index"):
                item["selected_index"] = 0
        _:
            Utils.error()

func _set_items(value: Array) -> void:
    items = value
    for item in items:
        _normalize_item(item)
    _update_children()

func _get_items() -> Array:
    return items

func _set_row_height(value: float) -> void:
    row_height = value
    _update_children()

func _get_row_height() -> float:
    return row_height

func _set_padding_horizontal(value: float) -> void:
    padding_horizontal = value
    _update_children()

func _get_padding_horizontal() -> float:
    return padding_horizontal
