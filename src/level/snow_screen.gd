tool
extends Node2D
class_name SnowScreen

const DEFAULT_PARTICLE_COUNT_PER_PIXEL := 0.0002
const DEFAULT_SNOW_VELOCITY_WITH_NO_WIND_PIXELS_PER_SECOND := \
        Vector2(0.0, 150.0)
const WINDINESS_TO_PIXELS_PER_SEC_MULTIPLIER := 150.0
const PIXELS_PER_SECOND_TO_SHADER_SPEED_VALUE_MULTIPLIER := 1.0
const PARTICLE_LIFETIME_MULTIPLIER := 1.3

const _DEFAULT_IN_EDITOR_SIZE := Vector2(480.0, 480.0)

var windiness := Vector2.ZERO setget _set_windiness
var snow_density_multiplier := 1.0 setget _set_snow_density_multiplier

var _viewport_size := Vector2.ZERO

func _ready() -> void:
    Global.connect( \
            "display_resized", \
            self, \
            "_update_screen_size")
    _update_screen_size()
    if Engine.editor_hint:
        _update_shader_args()

func _update_screen_size() -> void:
    _viewport_size = \
            _DEFAULT_IN_EDITOR_SIZE if \
            Engine.editor_hint else \
            get_viewport().size
    _update_shader_args()

func _set_windiness(value: Vector2) -> void:
    if windiness != value:
        windiness = value
        _update_shader_args()

func _set_snow_density_multiplier(value: float) -> void:
    if snow_density_multiplier != value:
        snow_density_multiplier = value
        _update_shader_args()

func _update_shader_args() -> void:
    var velocity := \
            windiness * WINDINESS_TO_PIXELS_PER_SEC_MULTIPLIER + \
            DEFAULT_SNOW_VELOCITY_WITH_NO_WIND_PIXELS_PER_SECOND
    var direction_2d := velocity.normalized()
    var direction := Vector3(direction_2d.x, direction_2d.y, 0.0)
    var speed_pixels_per_sec := velocity.length()
    var shader_speed_value := \
            speed_pixels_per_sec * \
            PIXELS_PER_SECOND_TO_SHADER_SPEED_VALUE_MULTIPLIER
    
    # Account for the horizontal distance travelled by the time a snowflake
    # reaches the bottom of the screen (so we don't have a bottom corner that
    # never sees a snowflake).
    # TODO: Consider also accounting for `spread` here.
    var horizontal_margin_left := \
            0.0 if \
            direction_2d.x <= 0 else \
            direction_2d.x / direction_2d.y * _viewport_size.y
    var horizontal_margin_right := \
            0.0 if \
            direction_2d.x >= 0 else \
            -direction_2d.x / direction_2d.y * _viewport_size.y
    var particle_region := Rect2( \
            -horizontal_margin_left, \
            0.0, \
            _viewport_size.x + \
                    horizontal_margin_right + \
                    horizontal_margin_left, \
            _viewport_size.y)
    var node_position := Vector2( \
            particle_region.position.x + particle_region.size.x * 0.5, \
            0.0)
    
    var emission_extents := Vector3(particle_region.size.x * 0.5, 0.0, 0.0)
    var region_diagonal_length := particle_region.size.length()
    var time_to_cross_screen_sec := \
            region_diagonal_length / speed_pixels_per_sec
    var particle_duration := \
            time_to_cross_screen_sec * PARTICLE_LIFETIME_MULTIPLIER
    var particle_count := \
            DEFAULT_PARTICLE_COUNT_PER_PIXEL * \
            _viewport_size.x * _viewport_size.y * \
            PARTICLE_LIFETIME_MULTIPLIER * \
            snow_density_multiplier
    
    position = node_position
    for particles_node in [$SnowFlakes1, $SnowFlakes2]:
        particles_node.amount = particle_count
        particles_node.lifetime = particle_duration
        particles_node.preprocess = particle_duration
        particles_node.visibility_rect = particle_region
        particles_node.process_material.emission_box_extents = emission_extents
        particles_node.process_material.direction = direction
        particles_node.process_material.initial_velocity = shader_speed_value
