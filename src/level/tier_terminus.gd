extends Position2D
class_name TierTerminus

const _CELL_SIZE := Vector2(32.0, 32.0)

const SURFACE_DEPTH := _CELL_SIZE.y
const SURFACE_DEPTH_DIVISIONS_COUNT := 16
const SURFACE_ALPHA_END_RATIO := 0.1

export var width: float = _CELL_SIZE.x * 12 setget _set_width

var surface_color: Color

func _init(surface_color: Color) -> void:
    self.surface_color = surface_color

func _ready() -> void:
    update()

func _set_width(value: float) -> void:
    width = value
    update()

func _draw() -> void:
    if Engine.editor_hint:
        var horizontal_extent := width * 0.5
        var top_left := Vector2( \
                -horizontal_extent, \
                0.0)
        var top_right := Vector2( \
                horizontal_extent, \
                0.0)
        var bottom_left := Vector2( \
                -horizontal_extent, \
                _CELL_SIZE.y)
        var bottom_right := Vector2( \
                horizontal_extent, \
                _CELL_SIZE.y)
        
        var surface_depth_division_size := \
            SURFACE_DEPTH / SURFACE_DEPTH_DIVISIONS_COUNT
        var surface_depth_division_offset := \
            Vector2(0.0, surface_depth_division_size)
        var color := surface_color
        var alpha_start := color.a
        var alpha_end := alpha_start * SURFACE_ALPHA_END_RATIO
        
        var polyline: PoolVector2Array
        var translation: Vector2
        var progress: float
        var left: Vector2
        var right: Vector2
        
        for i in range(SURFACE_DEPTH_DIVISIONS_COUNT):
            translation = surface_depth_division_offset * (i + 0.5)
            left = top_left + translation
            right = top_right + translation
            progress = i / (SURFACE_DEPTH_DIVISIONS_COUNT - 1.0)
            color.a = alpha_start + progress * (alpha_end - alpha_start)
            draw_line( \
                    left, \
                    right, \
                    color, \
                    surface_depth_division_size)
        
        draw_circle( \
                top_left, \
                1.0, \
                surface_color)
        draw_circle( \
                top_right, \
                1.0, \
                surface_color)
        draw_circle( \
                bottom_left, \
                1.0, \
                surface_color)
        draw_circle( \
                bottom_right, \
                1.0, \
                surface_color)
