extends Player
class_name TuberPlayer

const JUMP_SFX_STREAM := preload("res://assets/sfx/tuber_jump.wav")
const LAND_SFX_STREAM := preload("res://assets/sfx/tuber_land.wav")
const BOUNCE_SFX_STREAM := preload("res://assets/sfx/tuber_bounce.wav")

var GRAVITY_FAST_FALL: float = Geometry.GRAVITY
const SLOW_RISE_GRAVITY_MULTIPLIER := 0.38
const RISE_DOUBLE_JUMP_GRAVITY_MULTIPLIER := 0.68
const JUMP_BOOST := -1000.0
const WALL_BOUNCE_BOOST := 200.0
const FLOOR_BOUNCE_BOOST := -1000.0
const IN_AIR_HORIZONTAL_ACCELERATION := 3200.0
const WALK_ACCELERATION := 20.0
const WALK_ACCELERATION_FOR_LOW_SPEED_LOW_FRICTION := 250.0
const LOW_SPEED_THRESHOLD_FOR_WALK_ACCELERATION_FOR_LOW_SPEED_LOW_FRICTION := 500.0
const MIN_HORIZONTAL_SPEED := 5.0
const MAX_HORIZONTAL_SPEED := 500.0
const MIN_VERTICAL_SPEED := 0.0
const MAX_VERTICAL_SPEED := 4000.0
const MIN_SPEED_TO_MAINTAIN_VERTICAL_COLLISION := 15.0
const FRICTION_COEFFICIENT := 0.02

var horizontal_facing_sign := 1
var horizontal_acceleration_sign := 0

var is_touching_floor := false
var is_touching_ceiling := false
var is_touching_wall := false
var is_touching_left_wall := false
var is_touching_right_wall := false
var toward_wall_sign := 0
var just_touched_floor := false
var just_touched_ceiling := false
var just_touched_wall := false

var just_triggered_jump := false
var is_rising_from_jump := false
var jump_count := 0
# FIXME: Add double jumps after reaching a certain tier.
var max_jump_count := 1

var jump_sfx_player: AudioStreamPlayer
var land_sfx_player: AudioStreamPlayer
var bounce_sfx_player: AudioStreamPlayer

func _init() -> void:
    _set_camera()
    _init_sfx_players()

func _init_sfx_players() -> void:
    jump_sfx_player = AudioStreamPlayer.new()
    jump_sfx_player.stream = JUMP_SFX_STREAM
    add_child(jump_sfx_player)
    
    land_sfx_player = AudioStreamPlayer.new()
    land_sfx_player.stream = LAND_SFX_STREAM
    add_child(land_sfx_player)
    
    bounce_sfx_player = AudioStreamPlayer.new()
    bounce_sfx_player.stream = BOUNCE_SFX_STREAM
    add_child(bounce_sfx_player)

func _physics_process(delta_sec: float) -> void:
    ._physics_process(delta_sec)
    
    # We don't need to multiply velocity by delta because MoveAndSlide already
    # takes delta time into account.
    # TODO: Use the remaining pre-collision movement that move_and_slide
    #       returns. This might be needed in order to move along slopes?
    move_and_slide( \
            velocity, \
            Geometry.UP, \
            false, \
            4, \
            Geometry.FLOOR_MAX_ANGLE)

# Calculates basic surface-related state for the current frame.
func _update_surface_state() -> void:
    var was_touching_floor := is_touching_floor
    var was_touching_ceiling := is_touching_ceiling
    var was_touching_wall := is_touching_wall
    is_touching_floor = is_on_floor()
    is_touching_ceiling = is_on_ceiling()
    is_touching_wall = is_on_wall()
    just_touched_floor = !was_touching_floor and is_touching_floor
    just_touched_ceiling = !was_touching_ceiling and is_touching_ceiling
    just_touched_wall = !was_touching_wall and is_touching_wall
    var which_wall: int = Utils.get_which_wall_collided_for_body(self)
    is_touching_left_wall = which_wall == SurfaceSide.LEFT_WALL
    is_touching_right_wall = which_wall == SurfaceSide.RIGHT_WALL
    toward_wall_sign = \
            (0 if !is_touching_wall else \
            (1 if which_wall == SurfaceSide.RIGHT_WALL else \
            -1))

# Calculate what actions occur during this frame.
func _update_actions(delta_sec: float) -> void:
    if Input.is_action_pressed("move_right"):
        horizontal_facing_sign = 1
    elif Input.is_action_pressed("move_left"):
        horizontal_facing_sign = -1
    
    if Input.is_action_pressed("move_right"):
        horizontal_acceleration_sign = 1
    elif Input.is_action_pressed("move_left"):
        horizontal_acceleration_sign = -1
    else:
        horizontal_acceleration_sign = 0
    
    if is_touching_ceiling:
        is_rising_from_jump = false
    
# Updates physics and player states in response to the current actions.
func _process_actions(delta_sec: float) -> void:
    just_triggered_jump = false
    
    # Bounce horizontal velocity off of walls.
    if just_touched_wall:
        velocity.x = -velocity.x
        velocity.x += \
                WALL_BOUNCE_BOOST if velocity.x > 0 else -WALL_BOUNCE_BOOST
    
    if is_touching_floor:
        jump_count = 0
        is_rising_from_jump = false
        
        # The move_and_slide system depends on some vertical gravity always pushing
        # the player into the floor. If we just zero this out, is_on_floor() will
        # give false negatives.
        velocity.y = MIN_SPEED_TO_MAINTAIN_VERTICAL_COLLISION
        
        # Jump.
        if Input.is_action_just_pressed("jump"):
            jump_count = 1
            just_triggered_jump = true
            is_rising_from_jump = true
            velocity.y = JUMP_BOOST
            
        else:
            var friction_multiplier := \
                    Utils.get_floor_friction_multiplier(self)
            assert(friction_multiplier != 0)
            
            var walk_acceleration := \
                    WALK_ACCELERATION_FOR_LOW_SPEED_LOW_FRICTION if \
                    abs(velocity.x) < \
                            LOW_SPEED_THRESHOLD_FOR_WALK_ACCELERATION_FOR_LOW_SPEED_LOW_FRICTION and \
                            friction_multiplier < 1.0 else \
                    WALK_ACCELERATION
            
            # Horizontal movement.
            velocity.x += \
                    walk_acceleration * \
                    horizontal_acceleration_sign * \
                    friction_multiplier
            
            # Friction.
            if horizontal_acceleration_sign == 0 or \
                    (horizontal_acceleration_sign > 0) != (velocity.x > 0):
                var friction_offset: float = \
                        friction_multiplier * \
                        FRICTION_COEFFICIENT * \
                        GRAVITY_FAST_FALL
                friction_offset = clamp(friction_offset, 0, abs(velocity.x))
                velocity.x += -sign(velocity.x) * friction_offset
    else:
        # If the player falls off a wall or ledge, then that's considered the first
        # jump.
        jump_count = max(jump_count, 1)
        var is_first_jump: bool = jump_count == 1
        
        # Handle the transition from jump rise to fall.
        if is_rising_from_jump and velocity.y >= 0:
            is_rising_from_jump = false
        if !is_rising_from_jump:
            velocity.y = max(velocity.y, 0)
        
        # Default movement update while in air.
        velocity = Utils.update_velocity_in_air( \
                velocity, \
                delta_sec, \
                Input.is_action_pressed("jump"), \
                is_first_jump, \
                horizontal_acceleration_sign, \
                IN_AIR_HORIZONTAL_ACCELERATION, \
                SLOW_RISE_GRAVITY_MULTIPLIER, \
                RISE_DOUBLE_JUMP_GRAVITY_MULTIPLIER, \
                GRAVITY_FAST_FALL)
        
        # A jump while in air (a "double jump").
        if Input.is_action_just_pressed("jump") and \
                jump_count < max_jump_count:
            jump_count += 1
            just_triggered_jump = true
            is_rising_from_jump = true
            velocity.y = JUMP_BOOST
    
    # Cap velocity beyond min/max values.
    velocity = Utils.cap_velocity( \
            velocity, \
            horizontal_acceleration_sign == 0, \
            MIN_HORIZONTAL_SPEED, \
            MAX_HORIZONTAL_SPEED, \
            MIN_VERTICAL_SPEED, \
            MAX_VERTICAL_SPEED)

# Updates the animation state for the current frame.
func _process_animation() -> void:
    # Flip the horizontal direction of the animation according to which way the
    # player is facing.
    if horizontal_facing_sign == 1:
        animator.face_right()
    elif horizontal_facing_sign == -1:
        animator.face_left()
    
    if is_touching_floor:
        if Input.is_action_pressed("move_right") or \
                Input.is_action_pressed("move_left"):
            animator.run()
        else:
            animator.stand()
    else:
        # Is in the air.
        if is_rising_from_jump:
            animator.jump_rise()
        else:
            animator.jump_fall()

# Updates sounds for the current frame.
func _process_sfx() -> void:
    if just_triggered_jump:
        jump_sfx_player.play()
    
    if just_touched_floor or just_touched_ceiling:
        land_sfx_player.play()
    
    if just_touched_wall:
        bounce_sfx_player.play()
