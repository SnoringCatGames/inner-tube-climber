tool
extends Sprite
class_name FogScreen

const _DEFAULT_IN_EDITOR_SIZE := Vector2(768.0, 512.0)

var hole_radius := 0.0 setget _set_hole_radius
var player_position := Vector2.ZERO setget _set_player_position
var screen_size := Vector2.ZERO
var screen_opacity := 0.0 setget _set_screen_opacity
var screen_color := Color.from_hsv(0.628, 0.21, 0.94, 1.0) setget \
        _set_screen_color

var canvas_transform := Transform2D.IDENTITY

func _ready() -> void:
    Global.connect( \
            "display_resized", \
            self, \
            "_update_fog_screen_size")
    _update_fog_screen_size()
    if Engine.editor_hint:
        _set_player_position(_DEFAULT_IN_EDITOR_SIZE * 0.5)
        _set_hole_radius(_DEFAULT_IN_EDITOR_SIZE.y * 0.25)
        _set_screen_opacity(1.0)

func _update_fog_screen_size() -> void:
    var viewport_size := \
            _DEFAULT_IN_EDITOR_SIZE if \
            Engine.editor_hint else \
            get_viewport().size
    
    if screen_size != viewport_size:
        screen_size = viewport_size
        scale = screen_size
        position = screen_size
        material.set_shader_param( \
                "region_size", \
                screen_size)
    
    _set_player_position(player_position)

func _set_player_position(value: Vector2) -> void:
    var next_canvas_transform: Transform2D = \
            Global.level.get_canvas_transform()
    if player_position != value or \
            canvas_transform != next_canvas_transform:
        player_position = value
        canvas_transform = next_canvas_transform
        var viewport := get_viewport()
        var game_area_region: Rect2 = Global.get_game_area_region()
        var game_area_margin := (viewport.size - game_area_region.size) * 0.5
        var hole_position_in_viewport_space: Vector2 = \
                canvas_transform * \
                player_position + \
                game_area_margin
        material.set_shader_param( \
                "hole_position", \
                hole_position_in_viewport_space)

func _set_hole_radius(value: float) -> void:
    if hole_radius != value:
        hole_radius = value
        material.set_shader_param( \
                "hole_radius", \
                hole_radius)

func _set_screen_opacity(value: float) -> void:
    if screen_opacity != value:
        screen_opacity = value
        material.set_shader_param( \
                "opacity", \
                screen_opacity)

func _set_screen_color(value: Color) -> void:
    if screen_color != value:
        screen_color = value
        material.set_shader_param( \
                "screen_color", \
                screen_color)
