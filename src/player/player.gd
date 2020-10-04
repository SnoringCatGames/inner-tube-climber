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

# Calculates basic surface-related state for the current frame.
func _update_surface_state() -> void:
    pass

# Calculate what actions occur during this frame.
func _update_actions(delta_sec: float) -> void:
    pass
    
# Updates physics and player states in response to the current actions.
func _process_actions(delta_sec: float) -> void:
    pass

# Updates the animation state for the current frame.
func _process_animation() -> void:
    pass

# Updates sounds for the current frame.
func _process_sfx() -> void:
    pass
