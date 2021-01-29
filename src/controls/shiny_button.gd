tool
extends Button
class_name ShinyButton

const SHINE_TEXTURE := \
        preload("res://assets/images/gui/shine-line-fat-sharp-x4.png")
const SHINE_DURATION_SEC := 0.35
const SHINE_INTERVAL_SEC := 3.5
const COLOR_PULSE_DURATION_SEC := 1.2
const COLOR_PULSE_INTERVAL_SEC := 2.4
var COLOR_PULSE_COLOR := Constants.INDICATOR_BLUE_COLOR

export var texture: Texture setget _set_texture,_get_texture
export var texture_scale := Vector2(1.0, 1.0) setget \
        _set_texture_scale,_get_texture_scale
export var is_shiny := false setget _set_is_shiny,_get_is_shiny
export var includes_color_pulse := false setget \
        _set_includes_color_pulse,_get_includes_color_pulse
export var is_font_xl := false setget _set_is_font_xl,_get_is_font_xl

var shine_interval_id := -1
var color_pulse_interval_id := -1

var shine_start_x: float
var shine_end_x: float

var button_style_normal: StyleBox
var button_style_hover: StyleBox
var button_style_pressed: StyleBox
var button_style_pulse: StyleBoxFlat

var shine_tween := Tween.new()
var color_pulse_tween := Tween.new()

func _ready() -> void:
    button_style_normal = $MarginContainer/BottomButton.get_stylebox("normal")
    button_style_hover = $MarginContainer/BottomButton.get_stylebox("hover")
    button_style_pressed = \
            $MarginContainer/BottomButton.get_stylebox("pressed")
    
    add_child(shine_tween)
    add_child(color_pulse_tween)
    $MarginContainer/TopButton.connect( \
            "pressed", self, "_on_pressed")
    $MarginContainer/TopButton.connect( \
            "mouse_entered", self, "_on_mouse_entered")
    $MarginContainer/TopButton.connect( \
            "mouse_exited", self, "_on_mouse_exited")
    $MarginContainer/TopButton.connect( \
            "button_down", self, "_on_button_down")
    $MarginContainer/TopButton.connect( \
            "button_up", self, "_on_button_up")
    Global.connect( \
            "display_resized", self, "update")
    update()

func update() -> void:
    _deferred_update()

func _deferred_update() -> void:
    var half_size := rect_size / 2.0
    var shine_base_position: Vector2 = half_size
    shine_start_x = shine_base_position.x - rect_size.x
    shine_end_x = shine_base_position.x + rect_size.x
    
    button_style_pulse = StyleBoxFlat.new()
    
    $MarginContainer.rect_size = rect_size
    $MarginContainer/BottomButton.text = text
    $MarginContainer/ShineLine.position = \
            Vector2(shine_start_x, shine_base_position.y)
    $MarginContainer/TextureWrapper/TextureRect.texture = texture
    $MarginContainer/TextureWrapper/TextureRect.rect_scale = texture_scale
    $MarginContainer/TextureWrapper/TextureRect.rect_size = \
            rect_size / texture_scale
    var font := \
            Constants.MAIN_FONT_XL if \
            is_font_xl else \
            Constants.MAIN_FONT_NORMAL
    $MarginContainer/BottomButton.add_font_override( \
            "font", \
            font)
    
    shine_tween.stop_all()
    Time.clear_interval(shine_interval_id)
    
    color_pulse_tween.stop_all()
    Time.clear_interval(color_pulse_interval_id)
    $MarginContainer/BottomButton.add_stylebox_override( \
            "normal", \
            button_style_normal)
    
    if is_shiny:
        shine_interval_id = Time.set_interval( \
                funcref(self, "_trigger_shine"), \
                SHINE_INTERVAL_SEC)
    
    if includes_color_pulse:
        color_pulse_interval_id = Time.set_interval( \
                funcref(self, "_trigger_color_pulse"), \
                COLOR_PULSE_INTERVAL_SEC)

func _on_mouse_entered() -> void:
    $MarginContainer/BottomButton \
            .add_stylebox_override("normal", button_style_hover)

func _on_mouse_exited() -> void:
    $MarginContainer/BottomButton \
            .add_stylebox_override("normal", button_style_normal)

func _on_button_down() -> void:
    $MarginContainer/BottomButton \
            .add_stylebox_override("normal", button_style_pressed)

func _on_button_up() -> void:
    $MarginContainer/BottomButton \
            .add_stylebox_override("normal", button_style_hover)

func _trigger_shine() -> void:
    shine_tween.interpolate_property( \
            $MarginContainer/ShineLine, \
            "position:x", \
            shine_start_x, \
            shine_end_x, \
            SHINE_DURATION_SEC, \
            Tween.TRANS_LINEAR, \
            Tween.EASE_IN_OUT)
    shine_tween.start()

func _trigger_color_pulse() -> void:
    # Give priority to normal button state styling.
    if $MarginContainer/TopButton.is_hovered() or \
            $MarginContainer/TopButton.is_pressed():
        return
    
    var color_original: Color = \
            button_style_normal.bg_color if \
            button_style_normal is StyleBoxFlat else \
            Constants.BUTTON_COLOR_NORMAL
    var color_pulse: Color = COLOR_PULSE_COLOR
    var pulse_half_duration := COLOR_PULSE_DURATION_SEC / 2.0
    
    button_style_pulse.bg_color = color_original
    $MarginContainer/BottomButton \
            .add_stylebox_override("normal", button_style_pulse)
    
    color_pulse_tween.interpolate_property( \
            button_style_pulse, \
            "bg_color", \
            color_original, \
            color_pulse, \
            pulse_half_duration, \
            Tween.TRANS_SINE, \
            Tween.EASE_IN_OUT)
    color_pulse_tween.interpolate_property( \
            button_style_pulse, \
            "bg_color", \
            color_pulse, \
            color_original, \
            pulse_half_duration, \
            Tween.TRANS_SINE, \
            Tween.EASE_IN_OUT, \
            pulse_half_duration)
    color_pulse_tween.start()

func _set_texture(value: Texture) -> void:
    texture = value
    update()

func _get_texture() -> Texture:
    return texture

func _set_texture_scale(value: Vector2) -> void:
    texture_scale = value
    update()

func _get_texture_scale() -> Vector2:
    return texture_scale

func _set_is_shiny(value: bool) -> void:
    is_shiny = value
    update()

func _get_is_shiny() -> bool:
    return is_shiny

func _set_includes_color_pulse(value: bool) -> void:
    includes_color_pulse = value
    update()

func _get_includes_color_pulse() -> bool:
    return includes_color_pulse

func _set_is_font_xl(value: bool) -> void:
    is_font_xl = value
    update()

func _get_is_font_xl() -> bool:
    return is_font_xl

func _on_pressed() -> void:
    emit_signal("pressed")
