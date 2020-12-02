extends KinematicBody2D
class_name Player

var velocity := Vector2.ZERO

var animator: PlayerAnimator

func _ready() -> void:
    var animators: Array = Utils.get_children_by_type( \
            self, \
            PlayerAnimator)
    assert(animators.size() == 1)
    animator = animators[0]

func _physics_process(delta_sec: float) -> void:
    _update_surface_state()
    _update_actions(delta_sec)
    
    _process_actions(delta_sec)
    _process_animation()
    _process_sfx()
    
    _apply_movement()

func _apply_movement() -> void:
    pass

# Calculates basic surface-related state for the current frame.
func _update_surface_state() -> void:
    pass

# Calculate what actions occur during this frame.
func _update_actions(_delta_sec: float) -> void:
    _delta_sec *= Time.physics_framerate_multiplier
    
    pass
    
# Updates physics and player states in response to the current actions.
func _process_actions(_delta_sec: float) -> void:
    _delta_sec *= Time.physics_framerate_multiplier
    
    pass

# Updates the animation state for the current frame.
func _process_animation() -> void:
    pass

# Updates sounds for the current frame.
func _process_sfx() -> void:
    pass

static func get_surface_collision( \
        body: KinematicBody2D, \
        surface_state: PlayerSurfaceState) -> KinematicCollision2D:
    var closest_normal_diff: float = PI
    var closest_collision: KinematicCollision2D
    var current_normal_diff: float
    var current_collision: KinematicCollision2D
    for i in range(surface_state.collision_count):
        current_collision = body.get_slide_collision(i)
        
        if surface_state.is_touching_floor:
            current_normal_diff = \
                    abs(current_collision.normal.angle_to(Geometry.UP))
        elif surface_state.is_touching_ceiling:
            current_normal_diff = \
                    abs(current_collision.normal.angle_to(Geometry.DOWN))
        elif surface_state.is_touching_left_wall:
            current_normal_diff = \
                    abs(current_collision.normal.angle_to(Geometry.RIGHT))
        elif surface_state.is_touching_right_wall:
            current_normal_diff = \
                    abs(current_collision.normal.angle_to(Geometry.LEFT))
        else:
            continue
        
        if current_normal_diff < closest_normal_diff:
            closest_normal_diff = current_normal_diff
            closest_collision = current_collision
    
    return closest_collision
