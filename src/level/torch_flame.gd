extends Node2D
class_name TorchFlame

const WINDINESS_MULTIPLIER := Vector2(0.6, 0.3)
const MAX_OUTER_FLAME_SPEED_PIXELS_PER_SEC := 140.0
const INITIAL_VELOCITY_DEFAULT_PIXELS_PER_SEC := Vector2(0.0, -106.99)
const INNER_FLAME_TO_OUTER_FLAME_SPEED_RATIO := 0.655
const SMOKE_TO_OUTER_FLAME_SPEED_RATIO := 1.0

var windiness := Vector2.ZERO setget _set_windiness

# FIXME: -------------------------------
# - Add torch light emission node.
# - Make Player a light occluder for torch light.
# - Add a sparks particle node.

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
    var smoke_shader_speed_value := \
            outer_flame_shader_speed_value * \
            SMOKE_TO_OUTER_FLAME_SPEED_RATIO
    
    $Smoke.process_material.direction = direction
    $Smoke.process_material.initial_velocity = \
            smoke_shader_speed_value
    $OuterFlame.process_material.direction = direction
    $OuterFlame.process_material.initial_velocity = \
            outer_flame_shader_speed_value
    $InnerFlame.process_material.direction = direction
    $InnerFlame.process_material.initial_velocity = \
            inner_flame_shader_speed_value
