tool
extends Control
class_name ShinyButton

signal pressed

const SHINE_TEXTURE := \
        preload("res://assets/images/shine-line-fat-sharp-x4.png")
const SHINE_DURATION_SEC := 0.35
const SHINE_INTERVAL_SEC := 3.5
const COLOR_PULSE_DURATION_SEC := 0.8
const COLOR_PULSE_INTERVAL_SEC := 1.6
var COLOR_PULSE_COLOR := Constants.INDICATOR_BLUE_COLOR

export var text := "" setget _set_text,_get_text
export var texture: Texture setget _set_texture,_get_texture
export var texture_scale := Vector2.ONE setget \
        _set_texture_scale,_get_texture_scale
export var is_shiny := false setget _set_is_shiny,_get_is_shiny
export var includes_color_pulse := false setget \
        _set_includes_color_pulse,_get_includes_color_pulse

var shine_interval_id := -1
var color_pulse_interval_id := -1

var shine_start_x: float
var shine_end_x: float

var button_style_original: StyleBox
var button_style_pulse: StyleBoxFlat

var shine_tween := Tween.new()
var color_pulse_tween := Tween.new()

func _ready() -> void:
    add_child(shine_tween)
    add_child(color_pulse_tween)
    $TopButton.connect("pressed", self, "_on_pressed")
    update()

func update() -> void:
    _deferred_update()

func _deferred_update() -> void:
    var half_size := rect_size / 2.0
    var shine_base_position: Vector2 = half_size
    shine_start_x = shine_base_position.x - rect_size.x
    shine_end_x = shine_base_position.x + rect_size.x
    
    $BottomButton.text = text
    $ShineLine.position = Vector2(shine_start_x, shine_base_position.y)
    $TextureWrapper/TextureRect.texture = texture
    $TextureWrapper/TextureRect.rect_scale = texture_scale
    $TextureWrapper/TextureRect.rect_size = half_size
    
    if !is_shiny:
        shine_tween.stop_all()
        Time.clear_interval(shine_interval_id)
    
    if !includes_color_pulse:
        color_pulse_tween.stop_all()
        Time.clear_interval(color_pulse_interval_id)
        $BottomButton.add_stylebox_override( \
                "normal", \
                button_style_original)
    
    if is_shiny:
        shine_interval_id = Time.set_interval( \
                funcref(self, "trigger_shine"), \
                SHINE_INTERVAL_SEC)
    
    if includes_color_pulse:
        color_pulse_interval_id = Time.set_interval( \
                funcref(self, "trigger_color_pulse"), \
                COLOR_PULSE_INTERVAL_SEC)

func trigger_shine() -> void:
    shine_tween.interpolate_property( \
            $ShineLine, \
            "position:x", \
            shine_start_x, \
            shine_end_x, \
            SHINE_DURATION_SEC, \
            Tween.TRANS_LINEAR, \
            Tween.EASE_IN_OUT)
    shine_tween.start()

func trigger_color_pulse() -> void:
    var color_original: Color = \
            button_style_original.bg_color if \
            button_style_original is StyleBoxFlat else \
            Constants.BUTTON_COLOR
    var color_pulse: Color = COLOR_PULSE_COLOR
    var pulse_half_duration := COLOR_PULSE_DURATION_SEC / 2.0
    
    button_style_original = $BottomButton.get_stylebox("normal")
    button_style_pulse = StyleBoxFlat.new()
    button_style_pulse.bg_color = color_original
    $BottomButton.add_stylebox_override("normal", button_style_pulse)
    
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

func _set_text(value: String) -> void:
    text = value
    update()

func _get_text() -> String:
    return text

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

func _on_pressed() -> void:
    emit_signal("pressed")
