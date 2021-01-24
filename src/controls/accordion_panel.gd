tool
extends Control
class_name AccordionPanel

# FIXME: -------------------------------

signal header_pressed

const CARET_LEFT_NORMAL: Texture = \
        preload("res://assets/images/icons/left_caret_normal.png")

const CARET_SIZE_DEFAULT := Vector2(23.0, 32.0)
const CARET_SCALE := Vector2(1.0, 1.0)
const CARET_ROTATION_CLOSED := 180.0
const CARET_ROTATION_OPEN := 270.0

export var header_text := "" setget _set_header_text,_get_header_text
export var header_min_height := 0.0 setget \
        _set_header_min_height,_get_header_min_height
# FIXME: 
export var header_font: Font setget _set_header_font,_get_header_font
#export var header_font: Font = Constants.MAIN_FONT_NORMAL setget \
#        _set_header_font,_get_header_font
export var padding := Vector2(8.0, 4.0) setget _set_padding,_get_padding

var configuration_warning := ""

var _header: Button
var _projected_control: Control
var _caret: TextureRect

func _ready() -> void:
    # TODO: For some reason, when running in-editor, there can be extra
    #       children created?
    if _header != null:
        remove_child(_header)
        _header.queue_free()
    _create_header()
    _update_children()

func add_child(child: Node, legible_unique_name=false) -> void:
    .add_child(child, legible_unique_name)
    _update_children()

func remove_child(child: Node) -> void:
    .remove_child(child)
    _update_children()

func _create_header() -> void:
    _header = Button.new()
    _header.connect("pressed", self, "_on_header_pressed")
    add_child(_header)
    
    var header_style_normal := StyleBoxFlat.new()
    header_style_normal.bg_color = Constants.OPTION_BUTTON_COLOR_NORMAL
#    header_style_normal.content_margin_left = padding
#    header_style_normal.content_margin_top = padding
#    header_style_normal.content_margin_right = padding
#    header_style_normal.content_margin_bottom = padding
    _header.add_stylebox_override("normal", header_style_normal)
    
    var header_style_hover := StyleBoxFlat.new()
    header_style_hover.bg_color = Constants.OPTION_BUTTON_COLOR_HOVER
#    header_style_hover.content_margin_left = padding
#    header_style_hover.content_margin_top = padding
#    header_style_hover.content_margin_right = padding
#    header_style_hover.content_margin_bottom = padding
    _header.add_stylebox_override("hover", header_style_hover)
    
    var header_style_pressed := StyleBoxFlat.new()
    header_style_pressed.bg_color = Constants.OPTION_BUTTON_COLOR_PRESSED
#    header_style_pressed.content_margin_left = padding
#    header_style_pressed.content_margin_top = padding
#    header_style_pressed.content_margin_right = padding
#    header_style_pressed.content_margin_bottom = padding
    _header.add_stylebox_override("pressed", header_style_pressed)
    
    var hbox := HBoxContainer.new()
    hbox.add_constant_override("separation", padding.x)
    _header.add_child(hbox)
    
    var spacer1 := Control.new()
    spacer1.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    spacer1.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    hbox.add_child(spacer1)
    
    var caret_wrapper := Control.new()
    caret_wrapper.rect_min_size = CARET_SIZE_DEFAULT * CARET_SCALE
    caret_wrapper.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    caret_wrapper.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    hbox.add_child(caret_wrapper)
    
    _caret = TextureRect.new()
    _caret.texture = CARET_LEFT_NORMAL
    _caret.rect_pivot_offset = CARET_SIZE_DEFAULT / 2.0
    _caret.rect_scale = CARET_SCALE
    _caret.rect_rotation = CARET_ROTATION_CLOSED
    caret_wrapper.add_child(_caret)
    
    var label := Label.new()
    label.text = header_text
    label.align = Label.ALIGN_LEFT
    label.valign = Label.VALIGN_CENTER
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    hbox.add_child(label)
    
    var spacer2 := Control.new()
    spacer2.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    spacer2.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    hbox.add_child(spacer2)
    
    var texture_height := CARET_SIZE_DEFAULT.y * CARET_SCALE.y
    var label_height := label.rect_size.y
    var header_height := max( \
            header_min_height, \
            max( \
                    label_height, \
                    texture_height)) + \
            padding.y * 2.0
    _header.rect_size = Vector2(rect_size.x, header_height)
    hbox.rect_size = _header.rect_size

func _update_children() -> void:
    var children := get_children()
    if children.size() != 2:
        configuration_warning = \
                "Must define a child node." if \
                children.size() < 2 else \
                "Must define only one child node."
        update_configuration_warning()
        return
    
    move_child(_header, 0)
    
    var projected_node: Node = children[1]
    projected_node.size_flags_horizontal = Control.SIZE_SHRINK_END
    projected_node.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    _header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    if !(projected_node is Control):
        configuration_warning = "Child node must be of type 'Control'."
        update_configuration_warning()
        return
    
    _projected_control = projected_node
    _projected_control.rect_position.y = _header.rect_size.y
    _header.rect_position.y = 0.0
    
    configuration_warning = ""
    update_configuration_warning()
    
    call_deferred("_update_height")

func _update_height() -> void:
    # FIXME: set height differently if closed; tween height when transitioning;
    rect_min_size.y = \
            _header.rect_size.y + \
            _projected_control.rect_size.y

func _on_header_pressed() -> void:
    # FIXME: Rotate caret; tween the rotation;
    emit_signal("header_pressed")

func _get_configuration_warning() -> String:
    return configuration_warning

func _set_header_text(value: String) -> void:
    header_text = value
    if _header != null:
        _header.text = value

func _get_header_text() -> String:
    return header_text

func _set_header_min_height(value: float) -> void:
    header_min_height = value
    if _header != null:
        _update_children()

func _get_header_min_height() -> float:
    return header_min_height

func _set_header_font(value: Font) -> void:
    header_font = value
    if _header != null:
        _update_children()

func _get_header_font() -> Font:
    return header_font

func _set_padding(value: Vector2) -> void:
    padding = value
    if _header != null:
        _update_children()

func _get_padding() -> Vector2:
    return padding
