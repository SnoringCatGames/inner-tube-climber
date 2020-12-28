tool
extends Node2D
class_name TorchFlame

const VIEWPORT_SIZE := Vector2(720.0, 400.0)
const PIXEL_SIZE := 4.0
const OFFSET := Vector2(VIEWPORT_SIZE.x / 2.0, 360.0)
const WINDINESS_MULTIPLIER := Vector2(0.6, 0.3)
const MAX_OUTER_FLAME_SPEED_PIXELS_PER_SEC := 140.0
const INITIAL_VELOCITY_DEFAULT_PIXELS_PER_SEC := Vector2(0.0, -106.99)
const INNER_FLAME_TO_OUTER_FLAME_SPEED_RATIO := 0.655
const SPARKS_TO_OUTER_FLAME_SPEED_RATIO := 0.5
const SMOKE_TO_OUTER_FLAME_SPEED_RATIO := 1.0

var windiness := Vector2.ZERO setget _set_windiness

func _ready() -> void:
    $ViewportContainer.rect_size = VIEWPORT_SIZE
    $ViewportContainer.rect_position = -OFFSET
    $ViewportContainer/Viewport/Offset.position = OFFSET
    $ViewportContainer/Viewport/Offset.position.x -= PIXEL_SIZE / 2.0
    $ViewportContainer.material.set_shader_param( \
            "viewport_size", \
            VIEWPORT_SIZE)
    $ViewportContainer.material.set_shader_param( \
            "pixel_size", \
            PIXEL_SIZE)

func _set_windiness(value: Vector2) -> void:
    if windiness != value:
        windiness = value
        _update_shader_args()

func _update_shader_args() -> void:
    var wind_velocity := \
            windiness * SnowScreen.WINDINESS_TO_PIXELS_PER_SEC_MULTIPLIER
    wind_velocity.x *= WINDINESS_MULTIPLIER.x
    wind_velocity.y *= WINDINESS_MULTIPLIER.y
    var outer_flame_velocity := \
            wind_velocity + \
            INITIAL_VELOCITY_DEFAULT_PIXELS_PER_SEC
    var direction_2d := outer_flame_velocity.normalized()
    var direction := Vector3( \
            direction_2d.x, \
            direction_2d.y, \
            0.0)
    var outer_flame_speed_pixels_per_sec := outer_flame_velocity.length()
    outer_flame_speed_pixels_per_sec = clamp( \
            outer_flame_speed_pixels_per_sec, \
            0.0, \
            MAX_OUTER_FLAME_SPEED_PIXELS_PER_SEC)
    var outer_flame_shader_speed_value := \
            outer_flame_speed_pixels_per_sec * \
            SnowScreen.PIXELS_PER_SECOND_TO_SHADER_SPEED_VALUE_MULTIPLIER
    var inner_flame_shader_speed_value := \
            outer_flame_shader_speed_value * \
            INNER_FLAME_TO_OUTER_FLAME_SPEED_RATIO
    var sparks_shader_speed_value := \
            outer_flame_shader_speed_value * \
            SPARKS_TO_OUTER_FLAME_SPEED_RATIO
    var smoke_shader_speed_value := \
            outer_flame_shader_speed_value * \
            SMOKE_TO_OUTER_FLAME_SPEED_RATIO
    
    $ViewportContainer/Viewport/Offset/Smoke \
            .process_material.direction = direction
    $ViewportContainer/Viewport/Offset/Smoke \
            .process_material.initial_velocity = smoke_shader_speed_value
    $ViewportContainer/Viewport/Offset/OuterFlame \
            .process_material.direction = direction
    $ViewportContainer/Viewport/Offset/OuterFlame \
            .process_material.initial_velocity = outer_flame_shader_speed_value
    $ViewportContainer/Viewport/Offset/InnerFlame \
            .process_material.direction = direction
    $ViewportContainer/Viewport/Offset/InnerFlame \
            .process_material.initial_velocity = inner_flame_shader_speed_value
    $ViewportContainer/Viewport/Offset/Sparks \
            .process_material.direction = direction
    $ViewportContainer/Viewport/Offset/Sparks \
            .process_material.initial_velocity = sparks_shader_speed_value
