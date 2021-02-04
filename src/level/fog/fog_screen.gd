tool
extends Sprite
class_name FogScreen

const _DEFAULT_IN_EDITOR_SIZE := Vector2(768.0, 512.0)

var hole_radius := 0.0 setget _set_hole_radius
var player_position := Vector2.ZERO setget _set_player_position
var screen_size := Vector2.ZERO
var screen_opacity := 0.0 setget _set_screen_opacity
var secondary_color_opacity_multiplier := 0.0 setget \
        _set_secondary_color_opacity_multiplier
var primary_color := Color("#ffffff") setget _set_primary_color
var secondary_color := Color("#52c8ff") setget _set_secondary_color
var windiness := Vector2.ZERO setget _set_windiness

var _canvas_transform := Transform2D.IDENTITY

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
        _set_secondary_color_opacity_multiplier(1.0)
        _set_windiness(Vector2(0.5, 0.0))

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
            _canvas_transform != next_canvas_transform:
        player_position = value
        _canvas_transform = next_canvas_transform
        var viewport := get_viewport()
        var game_area_region: Rect2 = Global.get_game_area_region()
        var game_area_margin := (viewport.size - game_area_region.size) * 0.5
        var hole_position_in_viewport_space: Vector2 = \
                _canvas_transform * \
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

func _set_secondary_color_opacity_multiplier(value: float) -> void:
    if secondary_color_opacity_multiplier != value:
        secondary_color_opacity_multiplier = value
        material.set_shader_param( \
                "secondary_color_opacity_multiplier", \
                secondary_color_opacity_multiplier)

func _set_primary_color(value: Color) -> void:
    if primary_color != value:
        primary_color = value
        material.set_shader_param( \
                "primary_color", \
                primary_color)

func _set_secondary_color(value: Color) -> void:
    if secondary_color != value:
        secondary_color = value
        material.set_shader_param( \
                "secondary_color", \
                secondary_color)

func _set_windiness(value: Vector2) -> void:
    if windiness != value:
        windiness = value
        material.set_shader_param( \
                "windiness", \
                windiness)
