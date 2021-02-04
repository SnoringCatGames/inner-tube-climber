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

const BURST_SCALE := 1.6
const BURST_DURATION_SEC := 0.5

var windiness := Vector2.ZERO setget _set_windiness
var burst_tween: Tween

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
    
    burst_tween = Tween.new()
    add_child(burst_tween)
    
    if Engine.editor_hint:
        ignite(true)
    else:
        snuff()

func snuff() -> void:
    _update_lit(false, false)

func ignite(is_new_life: bool) -> void:
    _update_lit(true, is_new_life)
    if !is_new_life:
        var flare_up_duration_sec := BURST_DURATION_SEC * 0.67
        var flare_down_duration_sec := BURST_DURATION_SEC - flare_up_duration_sec
        burst_tween.interpolate_property( \
                $ViewportContainer/Viewport/Offset/Persistent, \
                "scale", \
                Vector2.ZERO, \
                Vector2(BURST_SCALE, BURST_SCALE), \
                flare_up_duration_sec, \
                Tween.TRANS_QUART, \
                Tween.EASE_IN_OUT)
        burst_tween.interpolate_property( \
                $ViewportContainer/Viewport/Offset/Persistent, \
                "scale", \
                Vector2(BURST_SCALE, BURST_SCALE), \
                Vector2.ONE, \
                flare_down_duration_sec, \
                Tween.TRANS_QUAD, \
                Tween.EASE_IN_OUT, \
                flare_up_duration_sec)
        burst_tween.start()

func _update_lit( \
        is_lit: bool, \
        is_new_life: bool) -> void:
    $ViewportContainer/Viewport/Offset/Persistent/Smoke.emitting = is_lit
    $ViewportContainer/Viewport/Offset/Persistent/OuterFlame.emitting = is_lit
    $ViewportContainer/Viewport/Offset/Persistent/InnerFlame.emitting = is_lit
    $ViewportContainer/Viewport/Offset/Persistent/Sparks.emitting = is_lit
    if is_new_life:
        $ViewportContainer/Viewport/Offset/Persistent/Smoke.preprocess = 1.0
        $ViewportContainer/Viewport/Offset/Persistent/OuterFlame \
                .preprocess = 1.0
        $ViewportContainer/Viewport/Offset/Persistent/InnerFlame \
                .preprocess = 1.0
        $ViewportContainer/Viewport/Offset/Persistent/Sparks.preprocess = 1.0
    else:
        $ViewportContainer/Viewport/Offset/Burst/OuterFlame.emitting = is_lit
        $ViewportContainer/Viewport/Offset/Burst/InnerFlame.emitting = is_lit
        $ViewportContainer/Viewport/Offset/Burst/Sparks.emitting = is_lit

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
    
    $ViewportContainer/Viewport/Offset/Persistent/Smoke \
            .process_material.direction = direction
    $ViewportContainer/Viewport/Offset/Persistent/Smoke \
            .process_material.initial_velocity = smoke_shader_speed_value
    $ViewportContainer/Viewport/Offset/Persistent/OuterFlame \
            .process_material.direction = direction
    $ViewportContainer/Viewport/Offset/Persistent/OuterFlame \
            .process_material.initial_velocity = outer_flame_shader_speed_value
    $ViewportContainer/Viewport/Offset/Persistent/InnerFlame \
            .process_material.direction = direction
    $ViewportContainer/Viewport/Offset/Persistent/InnerFlame \
            .process_material.initial_velocity = inner_flame_shader_speed_value
    $ViewportContainer/Viewport/Offset/Persistent/Sparks \
            .process_material.direction = direction
    $ViewportContainer/Viewport/Offset/Persistent/Sparks \
            .process_material.initial_velocity = sparks_shader_speed_value
