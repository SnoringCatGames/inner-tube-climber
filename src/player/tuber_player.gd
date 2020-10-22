extends Player
class_name TuberPlayer

var GRAVITY_FAST_FALL: float = Geometry.GRAVITY
const SLOW_RISE_GRAVITY_MULTIPLIER := 0.38
const RISE_DOUBLE_JUMP_GRAVITY_MULTIPLIER := 0.68
const JUMP_BOOST := -600.0
var WALL_BOUNCE_HORIZONTAL_BOOST := \
        -10.0 if Global.MOBILE_CONTROL_VERSION == 1 else 10.0
const WALL_BOUNCE_VERTICAL_BOOST := -200.0
const FLOOR_BOUNCE_BOOST := -800.0
var IN_AIR_HORIZONTAL_ACCELERATION := \
        600.0 if Global.MOBILE_CONTROL_VERSION == 1 else 500.0
var IN_AIR_HORIZONTAL_DECELERATION := \
        380.0 if Global.MOBILE_CONTROL_VERSION == 1 else 560.0
var WALK_ACCELERATION := \
        15.0 if Global.MOBILE_CONTROL_VERSION == 1 else 13.0
var WALK_ACCELERATION_FOR_LOW_SPEED_LOW_FRICTION := \
        250.0 if Global.MOBILE_CONTROL_VERSION == 1 else 200.0
const LOW_SPEED_THRESHOLD_FOR_WALK_ACCELERATION_FOR_LOW_SPEED_LOW_FRICTION := \
        500.0
const MIN_HORIZONTAL_SPEED := 5.0
const MAX_HORIZONTAL_IN_AIR_SPEED := 400.0
const MAX_HORIZONTAL_ON_FLOOR_SPEED := 350.0
const MIN_VERTICAL_SPEED := 0.0
const MAX_VERTICAL_SPEED := 4000.0
const MIN_SPEED_TO_MAINTAIN_VERTICAL_COLLISION := 15.0
var FRICTION_COEFFICIENT := \
        0.02 if Global.MOBILE_CONTROL_VERSION == 1 else 0.03
var WALL_BOUNCE_MOVEMENT_DELAY_SEC := \
        0.7 if Global.MOBILE_CONTROL_VERSION == 1 else 1.0
const JUMP_ANTICIPATION_FORGIVENESS_THRESHOLD_SEC := 0.2
const JUMP_DELAY_FORGIVENESS_THRESHOLD_SEC := 0.15

var surface_state := PlayerSurfaceState.new()

var just_triggered_jump := false
var is_rising_from_jump := false
var jump_count := 0
# FIXME: Add double jumps after reaching a certain tier.
var max_jump_count := 1

var has_hit_wall_since_pressing_move := false
var last_hit_wall_time := -INF
var is_in_post_bounce_horizontal_acceleration_grace_period := false
var was_last_jump_input_consumed := false
var last_jump_input_time := 0.0
var last_floor_fall_off_time := 0.0

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
    surface_state.collision_count = get_slide_count()
    
    var was_touching_floor := surface_state.is_touching_floor
    var was_touching_ceiling := surface_state.is_touching_ceiling
    var was_touching_wall := surface_state.is_touching_wall
    var was_touching_a_surface := surface_state.is_touching_a_surface
    
    surface_state.is_touching_floor = is_on_floor()
    surface_state.is_touching_ceiling = is_on_ceiling()
    surface_state.is_touching_wall = is_on_wall()
    surface_state.is_touching_a_surface = \
            surface_state.is_touching_floor or \
            surface_state.is_touching_ceiling or \
            surface_state.is_touching_wall
    
    surface_state.just_touched_floor = \
            !was_touching_floor and surface_state.is_touching_floor
    surface_state.just_touched_ceiling = \
            !was_touching_ceiling and surface_state.is_touching_ceiling
    surface_state.just_touched_wall = \
            !was_touching_wall and surface_state.is_touching_wall
    surface_state.just_left_floor = \
            was_touching_floor and !surface_state.is_touching_floor
    surface_state.just_left_ceiling = \
            was_touching_ceiling and !surface_state.is_touching_ceiling
    surface_state.just_left_wall = \
            was_touching_wall and !surface_state.is_touching_wall
    
    surface_state.just_entered_air = \
            was_touching_a_surface and \
                    !surface_state.is_touching_a_surface
    surface_state.just_left_air = \
            !was_touching_a_surface and \
                    surface_state.is_touching_a_surface
    
    var which_wall: int = Utils.get_which_wall_collided_for_body(self)
    surface_state.is_touching_left_wall = which_wall == SurfaceSide.LEFT_WALL
    surface_state.is_touching_right_wall = which_wall == SurfaceSide.RIGHT_WALL
    
    surface_state.toward_wall_sign = \
            (0 if !surface_state.is_touching_wall else \
            (1 if which_wall == SurfaceSide.RIGHT_WALL else \
            -1))
    
    if surface_state.just_touched_wall:
        has_hit_wall_since_pressing_move = true
    elif Input.is_action_just_pressed("move_left") or \
            Input.is_action_just_pressed("move_right") or \
            Input.is_action_just_released("move_left") or \
            Input.is_action_just_released("move_right"):
        has_hit_wall_since_pressing_move = false
    
    if surface_state.just_touched_wall:
        last_hit_wall_time = Time.elapsed_play_time_sec
    
    if surface_state.just_left_floor:
        last_floor_fall_off_time = Time.elapsed_play_time_sec
    
    is_in_post_bounce_horizontal_acceleration_grace_period = \
            has_hit_wall_since_pressing_move and \
            last_hit_wall_time >= \
                    Time.elapsed_play_time_sec - \
                    WALL_BOUNCE_MOVEMENT_DELAY_SEC and \
            !surface_state.is_touching_floor
    
    _update_tile_map_contact()

func _update_tile_map_contact() -> void:
    var collision := Player.get_surface_collision( \
            self, \
            surface_state)
    assert((collision != null) == surface_state.is_touching_a_surface)
    
    if surface_state.is_touching_a_surface:
        var next_touch_position := collision.position
        surface_state.just_changed_touch_position = \
                surface_state.just_left_air or \
                next_touch_position != surface_state.touch_position
        surface_state.touch_position = next_touch_position
        
        var next_touched_tile_map := collision.collider
        surface_state.just_changed_tile_map = \
                surface_state.just_left_air or \
                next_touched_tile_map != surface_state.touched_tile_map
        surface_state.touched_tile_map = next_touched_tile_map
        
        Geometry.get_collision_tile_map_coord( \
                surface_state.collision_tile_map_coord_result, \
                surface_state.touch_position, \
                surface_state.touched_tile_map, \
                surface_state.is_touching_floor, \
                surface_state.is_touching_ceiling, \
                surface_state.is_touching_left_wall, \
                surface_state.is_touching_right_wall, \
                false)
        if surface_state.collision_tile_map_coord_result.tile_map_coord == \
                Vector2.INF:
            for tile_map in get_tree().get_nodes_in_group( \
                    Global.GROUP_NAME_TIER_TILE_MAPS):
                Geometry.get_collision_tile_map_coord( \
                        surface_state.collision_tile_map_coord_result, \
                        surface_state.touch_position, \
                        tile_map, \
                        surface_state.is_touching_floor, \
                        surface_state.is_touching_ceiling, \
                        surface_state.is_touching_left_wall, \
                        surface_state.is_touching_right_wall, \
                        false)
                if surface_state.collision_tile_map_coord_result \
                        .tile_map_coord != Vector2.INF:
                    surface_state.touched_tile_map = tile_map
                    break
        if surface_state.collision_tile_map_coord_result.tile_map_coord == \
                Vector2.INF:
            Utils.error()
        
        if !surface_state.collision_tile_map_coord_result \
                .is_godot_floor_ceiling_detection_correct:
            match surface_state.collision_tile_map_coord_result.surface_side:
                SurfaceSide.FLOOR:
                    surface_state.is_touching_floor = true
                    surface_state.is_grabbing_floor = true
                    surface_state.is_touching_ceiling = false
                    surface_state.is_grabbing_ceiling = false
                    surface_state.just_touched_ceiling = false
                    surface_state.touched_side = SurfaceSide.FLOOR
                    surface_state.touched_surface_normal = Geometry.UP
                SurfaceSide.CEILING:
                    surface_state.is_touching_ceiling = true
                    surface_state.is_grabbing_ceiling = true
                    surface_state.is_touching_floor = false
                    surface_state.is_grabbing_floor = false
                    surface_state.just_touched_floor = false
                    surface_state.touched_side = SurfaceSide.CEILING
                    surface_state.touched_surface_normal = Geometry.DOWN
                SurfaceSide.LEFT_WALL, \
                SurfaceSide.RIGHT_WALL:
                    surface_state.is_touching_ceiling = \
                            !surface_state.is_touching_ceiling
                    surface_state.is_touching_floor = \
                            !surface_state.is_touching_floor
                    surface_state.is_grabbing_ceiling = false
                    surface_state.is_grabbing_floor = false
                    surface_state.just_touched_floor = false
                    surface_state.just_touched_ceiling = false
                _:
                    Utils.error()
        
        var next_touch_position_tile_map_coord := \
                surface_state.collision_tile_map_coord_result.tile_map_coord
        surface_state.just_changed_tile_map_coord = \
                surface_state.just_left_air or \
                next_touch_position_tile_map_coord != \
                        surface_state.touch_position_tile_map_coord
        surface_state.touch_position_tile_map_coord = \
                next_touch_position_tile_map_coord
        
        if surface_state.just_changed_tile_map_coord or \
                surface_state.just_changed_tile_map:
            surface_state.touched_tile_map_cell = \
                    surface_state.touched_tile_map.get_cellv( \
                            surface_state.touch_position_tile_map_coord)
            surface_state.friction = \
                    Nav.screens[ScreenType.GAME].level.get_friction_for_tile( \
                            surface_state.touched_tile_map.tile_set, \
                            surface_state.touched_tile_map_cell)
        
    else:
        if surface_state.just_entered_air:
            surface_state.just_changed_touch_position = true
            surface_state.just_changed_tile_map = true
            surface_state.just_changed_tile_map_coord = true
        
        surface_state.touch_position = Vector2.INF
        surface_state.touched_tile_map = null
        surface_state.touch_position_tile_map_coord = Vector2.INF
        surface_state.touched_tile_map_cell = TileMap.INVALID_CELL
        surface_state.friction = INF

# Calculate what actions occur during this frame.
func _update_actions(delta_sec: float) -> void:
    if Input.is_action_pressed("move_right"):
        surface_state.horizontal_facing_sign = 1
    elif Input.is_action_pressed("move_left"):
        surface_state.horizontal_facing_sign = -1
    
    surface_state.horizontal_acceleration_sign = 0
    if !is_in_post_bounce_horizontal_acceleration_grace_period:
        if Input.is_action_pressed("move_right"):
            surface_state.horizontal_acceleration_sign = 1
        elif Input.is_action_pressed("move_left"):
            surface_state.horizontal_acceleration_sign = -1
    
    if surface_state.is_touching_ceiling:
        is_rising_from_jump = false
    
    if Input.is_action_just_pressed("jump"):
        last_jump_input_time = Time.elapsed_play_time_sec
        was_last_jump_input_consumed = false
    
# Updates physics and player states in response to the current actions.
func _process_actions(delta_sec: float) -> void:
    just_triggered_jump = false
    
    # Bounce horizontal velocity off of walls.
    if surface_state.just_touched_wall:
        velocity.x = -velocity.x
        velocity.x += \
                WALL_BOUNCE_HORIZONTAL_BOOST if \
                velocity.x > 0 else \
                -WALL_BOUNCE_HORIZONTAL_BOOST
        if surface_state.is_touching_left_wall:
            velocity.x = max(velocity.x, 0)
        else:
            velocity.x = min(velocity.x, 0)
        
        velocity.y += WALL_BOUNCE_VERTICAL_BOOST
    
    var is_previous_jump_input_still_consumable := \
            !was_last_jump_input_consumed and \
            last_jump_input_time + \
                    JUMP_ANTICIPATION_FORGIVENESS_THRESHOLD_SEC > \
                    Time.elapsed_play_time_sec
    var is_jump_after_recent_fall_still_consumable := \
            last_floor_fall_off_time > \
            Time.elapsed_play_time_sec - \
                    JUMP_DELAY_FORGIVENESS_THRESHOLD_SEC
    
    if surface_state.is_touching_floor:
        assert(surface_state.friction >= 0.0 and \
                surface_state.friction <= 1.0)
        
        jump_count = 0
        surface_state.entered_air_by_jumping = false
        is_rising_from_jump = false
        
        # The move_and_slide system depends on some vertical gravity always pushing
        # the player into the floor. If we just zero this out, is_on_floor() will
        # give false negatives.
        velocity.y = MIN_SPEED_TO_MAINTAIN_VERTICAL_COLLISION
        
        # Jump.
        if Input.is_action_just_pressed("jump") or \
                is_previous_jump_input_still_consumable:
            jump_count = 1
            surface_state.entered_air_by_jumping = true
            just_triggered_jump = true
            is_rising_from_jump = true
            velocity.y = JUMP_BOOST
            was_last_jump_input_consumed = true
            
        else:
            var walk_acceleration := \
                    WALK_ACCELERATION_FOR_LOW_SPEED_LOW_FRICTION if \
                    abs(velocity.x) < \
                            LOW_SPEED_THRESHOLD_FOR_WALK_ACCELERATION_FOR_LOW_SPEED_LOW_FRICTION and \
                            surface_state.friction < 1.0 else \
                    WALK_ACCELERATION
            
            # Horizontal movement.
            velocity.x += \
                    walk_acceleration * \
                    surface_state.horizontal_acceleration_sign * \
                    surface_state.friction
            
            # Friction.
            if surface_state.horizontal_acceleration_sign == 0 or \
                    (surface_state.horizontal_acceleration_sign > 0) != \
                    (velocity.x > 0):
                var friction_offset: float = \
                        surface_state.friction * \
                        FRICTION_COEFFICIENT * \
                        GRAVITY_FAST_FALL
                friction_offset = clamp(friction_offset, 0, abs(velocity.x))
                velocity.x += -sign(velocity.x) * friction_offset
    else: # Is in the air.
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
        var horizontal_deceleration := \
                0.0 if \
                is_in_post_bounce_horizontal_acceleration_grace_period else \
                IN_AIR_HORIZONTAL_DECELERATION
        velocity = Utils.update_velocity_in_air( \
                velocity, \
                delta_sec, \
                Input.is_action_pressed("jump"), \
                is_first_jump, \
                surface_state.horizontal_acceleration_sign, \
                IN_AIR_HORIZONTAL_ACCELERATION, \
                horizontal_deceleration, \
                SLOW_RISE_GRAVITY_MULTIPLIER, \
                RISE_DOUBLE_JUMP_GRAVITY_MULTIPLIER, \
                GRAVITY_FAST_FALL)
        
        var is_an_initial_jump := \
                Input.is_action_just_pressed("jump") and \
                is_jump_after_recent_fall_still_consumable and \
                jump_count == 1
        # A jump while in air (a "double jump").
        var is_a_double_jump := \
                !is_an_initial_jump and \
                (Input.is_action_just_pressed("jump") or \
                is_previous_jump_input_still_consumable) and \
                jump_count < max_jump_count
        
        if is_an_initial_jump or is_a_double_jump:
            if is_an_initial_jump:
                jump_count = 1
            else:
                jump_count += 1
            just_triggered_jump = true
            is_rising_from_jump = true
            velocity.y = JUMP_BOOST
            was_last_jump_input_consumed = true
    
    # Cap velocity beyond min/max values.
    var max_horizontal_speed := \
            MAX_HORIZONTAL_ON_FLOOR_SPEED if \
            surface_state.is_touching_floor else \
            MAX_HORIZONTAL_IN_AIR_SPEED
    velocity = Utils.cap_velocity( \
            velocity, \
            surface_state.horizontal_acceleration_sign == 0, \
            MIN_HORIZONTAL_SPEED, \
            max_horizontal_speed, \
            MIN_VERTICAL_SPEED, \
            MAX_VERTICAL_SPEED)

# Updates the animation state for the current frame.
func _process_animation() -> void:
    # Flip the horizontal direction of the animation according to which way the
    # player is facing.
    if surface_state.horizontal_facing_sign == 1:
        animator.face_right()
    elif surface_state.horizontal_facing_sign == -1:
        animator.face_left()
    
    if surface_state.is_touching_floor:
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
        Audio.jump_sfx_player.play()
    
    if surface_state.just_touched_floor or surface_state.just_touched_ceiling:
        Audio.land_sfx_player.play()
    
    if surface_state.just_touched_wall:
        Audio.bounce_sfx_player.play()
