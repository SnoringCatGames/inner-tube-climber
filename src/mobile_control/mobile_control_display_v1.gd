extends MobileControlDisplay
class_name MobileControlDisplayV1

const RADIAL_GRADIENT_TEXTURE := \
        preload("res://assets/images/radial_gradient.png")

const JUMP_INDICATOR_TEXTURE := \
        preload("res://assets/images/jump_indicator.png")
const MOVE_SIDEWAYS_INDICATOR_TEXTURE := \
        preload("res://assets/images/move_sideways_indicator.png")
const MOBILE_CONTROL_BACKGROUND_TEXTURE := \
        preload("res://assets/images/mobile_control_background.png")

const OPACITY_UNPRESSED := 0.3
const OPACITY_PRESSED := 0.1

var jump_indicator: Sprite
var move_sideways_indicator: Sprite
# Array<Sprite>
var jump_backgrounds: Array
var move_sideways_backgrounds: Array

func _enter_tree() -> void:
    jump_indicator = Sprite.new()
    jump_indicator.texture = JUMP_INDICATOR_TEXTURE
    jump_indicator.z_index = 1
    jump_indicator.modulate.a = OPACITY_UNPRESSED
    add_child(jump_indicator)
    
    move_sideways_indicator = Sprite.new()
    move_sideways_indicator.texture = MOVE_SIDEWAYS_INDICATOR_TEXTURE
    move_sideways_indicator.z_index = 1
    move_sideways_indicator.modulate.a = OPACITY_UNPRESSED
    add_child(move_sideways_indicator)
    
    Global.connect( \
            "display_resized", \
            self, \
            "_on_display_resized")
    _on_display_resized()

func _on_display_resized() -> void:
    var viewport_size := get_viewport().size
    var jump_indicator_size := JUMP_INDICATOR_TEXTURE.get_size()
    var move_sideways_indicator_size := \
            MOVE_SIDEWAYS_INDICATOR_TEXTURE.get_size()
    var background_size := MOBILE_CONTROL_BACKGROUND_TEXTURE.get_size()
    
    var jump_indicator_position := Vector2( \
            jump_indicator_size.x / 2.0, \
            viewport_size.y - jump_indicator_size.y / 2.0)
    var move_sideways_indicator_position := Vector2( \
            viewport_size.x - move_sideways_indicator_size.x / 2.0, \
            viewport_size.y - move_sideways_indicator_size.y / 2.0)
    jump_indicator.position = jump_indicator_position
    move_sideways_indicator.position = move_sideways_indicator_position
    
    for background in move_sideways_backgrounds:
        remove_child(background)
    move_sideways_backgrounds.clear()
    for background in jump_backgrounds:
        remove_child(background)
    jump_backgrounds.clear()
    
    var background: Sprite
    var x := jump_indicator_size.x + background_size.x / 2.0
    while x < viewport_size.x / 2.0:
        background = Sprite.new()
        background.texture = MOBILE_CONTROL_BACKGROUND_TEXTURE
        background.z_index = 1
        background.modulate.a = OPACITY_UNPRESSED
        background.position = Vector2( \
                x, \
                viewport_size.y - background_size.y / 2.0)
        add_child(background)
        move_sideways_backgrounds.push_back(background)
        x += background_size.x
    x = viewport_size.x - \
            move_sideways_indicator_size.x - \
            background_size.x / 2.0
    while x > viewport_size.x / 2.0:
        background = Sprite.new()
        background.texture = MOBILE_CONTROL_BACKGROUND_TEXTURE
        background.z_index = 1
        background.modulate.a = OPACITY_UNPRESSED
        background.position = Vector2( \
                x, \
                viewport_size.y - background_size.y / 2.0)
        add_child(background)
        move_sideways_backgrounds.push_back(background)
        x -= background_size.x
    
    update()

func _draw() -> void:
    var viewport_size := get_viewport().size
    var background_size := MOBILE_CONTROL_BACKGROUND_TEXTURE.get_size()
    
    draw_line( \
            Vector2(viewport_size.x / 2.0, \
                    viewport_size.y - background_size.y), \
            Vector2(viewport_size.x / 2.0, \
                    viewport_size.y), \
            Color.from_hsv(0.0, 0.0, 1.0, 0.3), \
            6.0)
