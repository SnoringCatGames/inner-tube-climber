extends Player
class_name TuberPlayer

var PLAYER_STUCK_ANIMATION_CENTER_OFFSET := \
        Vector2(0.0, -18.0) * Constants.PLAYER_SIZE_MULTIPLIER

var GRAVITY_FAST_FALL: float = Geometry.GRAVITY
const SLOW_RISE_GRAVITY_MULTIPLIER := 0.38
const RISE_DOUBLE_JUMP_GRAVITY_MULTIPLIER := 0.68
const WINDINESS_MULTIPLIER := 80.0
const JUMP_BOOST := -600.0
var WALL_BOUNCE_HORIZONTAL_BOOST := \
        0.0 if Global.mobile_control_version == 1 else 20.0
const WALL_BOUNCE_VERTICAL_BOOST_MULTIPLIER := 0.6
const WALL_BOUNCE_VERTICAL_BOOST_OFFSET := -400.0
const FLOOR_BOUNCE_BOOST := -800.0
var IN_AIR_HORIZONTAL_ACCELERATION := \
        600.0 if Global.mobile_control_version == 1 else 500.0
var IN_AIR_HORIZONTAL_DECELERATION := \
        380.0 if Global.mobile_control_version == 1 else 560.0
var WALK_ACCELERATION := \
        15.0 if Global.mobile_control_version == 1 else 13.0
var WALK_ACCELERATION_FOR_LOW_SPEED_LOW_FRICTION := \
        250.0 if Global.mobile_control_version == 1 else 200.0
const LOW_SPEED_THRESHOLD_FOR_WALK_ACCELERATION_FOR_LOW_SPEED_LOW_FRICTION := \
        500.0
const MIN_HORIZONTAL_SPEED := 5.0
const MAX_HORIZONTAL_IN_AIR_SPEED := 400.0
const MAX_HORIZONTAL_ON_FLOOR_SPEED := 350.0
const MIN_VERTICAL_SPEED := 0.0
const MAX_VERTICAL_SPEED := 4000.0
const MIN_SPEED_TO_MAINTAIN_VERTICAL_COLLISION := 15.0
var FRICTION_COEFFICIENT := \
        0.02 if Global.mobile_control_version == 1 else 0.03
var WALL_BOUNCE_MOVEMENT_DELAY_SEC := \
        0.7 if Global.mobile_control_version == 1 else 1.0
const JUMP_ANTICIPATION_FORGIVENESS_THRESHOLD_SEC := 0.1
const JUMP_DELAY_FORGIVENESS_THRESHOLD_SEC := 0.1

const LIGHT_IMAGE_SIZE := Vector2(1024.0, 1024.0)
const PLAYER_LIGHT_TO_PEEP_HOLE_SIZE_RATIO := 1.3

const PLAY_WALK_EFFECT_THROTTLE_INTERVAL_SEC := 0.15
const PLAY_WALK_SOUND_THROTTLE_INTERVAL_SEC := 0.25

const STRETCH_DURATION_SEC := 0.2
const SQUASH_DURATION_SEC := 0.2

const STRETCH_SCALE_MULTIPLIER := Vector2(0.4, 1.5)
const SQUASH_SCALE_MULTIPLIER := Vector2(1.7, 0.5)

var STRETCH_DISPLACEMENT := Vector2( \
        0.0, \
        Constants.PLAYER_HALF_HEIGHT_DEFAULT * \
                (STRETCH_SCALE_MULTIPLIER.y - 1.0))
var SQUASH_DISPLACEMENT := Vector2( \
        0.0, \
        Constants.PLAYER_HALF_HEIGHT_DEFAULT * \
                (1.0 - SQUASH_SCALE_MULTIPLIER.y))

var is_stuck := true setget _set_is_stuck,_get_is_stuck

# Array<TileMap>
var tilemaps := []

var just_triggered_jump := false
var is_rising_from_jump := false
var jump_count := 0
var max_jump_count := 1

var has_hit_wall_since_pressing_move := false
var last_hit_wall_time := -INF
var is_in_post_bounce_horizontal_acceleration_grace_period := false
var was_last_jump_input_consumed := false
var last_jump_input_time := 0.0
var last_floor_departure_time := 0.0

var windiness := Vector2.ZERO

var effects_animator: EffectsAnimator

var stretch_tween: Tween
var squash_tween: Tween

var throttled_play_walk_effect: FuncRef = Time.throttle( \
        funcref(self, "_play_walk_effect"), \
        PLAY_WALK_EFFECT_THROTTLE_INTERVAL_SEC, \
        false)

var throttled_play_walk_sound: FuncRef = Time.throttle( \
        funcref(self, "_play_walk_sound"), \
        PLAY_WALK_SOUND_THROTTLE_INTERVAL_SEC, \
        false)

func _ready() -> void:
    stretch_tween = Tween.new()
    add_child(stretch_tween)
    squash_tween = Tween.new()
    add_child(squash_tween)
    
    effects_animator = EffectsAnimator.new(self, Global.level)
    
    $CollisionShape2D.shape.radius = \
            Constants.PLAYER_CAPSULE_RADIUS_DEFAULT
    $CollisionShape2D.shape.height = \
            Constants.PLAYER_CAPSULE_HEIGHT_DEFAULT
    on_new_tier()

func destroy() -> void:
    effects_animator.destroy()

func on_new_tier() -> void:
    tilemaps = get_tree().get_nodes_in_group( \
                    Constants.GROUP_NAME_TIER_TILE_MAPS)

func _apply_movement() -> void:
    if is_stuck:
        return
    
    # We don't need to multiply velocity by delta because MoveAndSlide already
    # takes delta time into account.
    # TODO: Use the remaining pre-collision movement that move_and_slide
    #       returns. This might be needed in order to move along slopes?
    move_and_slide( \
            velocity * Time.physics_framerate_multiplier, \
            Geometry.UP, \
            false, \
            4, \
            Geometry.FLOOR_MAX_ANGLE)

# Calculates basic surface-related state for the current frame.
func _update_surface_state() -> void:
    if is_stuck:
        return
    
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
        last_hit_wall_time = Time.elapsed_play_time_modified_sec
    
    if surface_state.just_left_floor:
        last_floor_departure_time = Time.elapsed_play_time_modified_sec
    
    is_in_post_bounce_horizontal_acceleration_grace_period = \
            has_hit_wall_since_pressing_move and \
            last_hit_wall_time >= \
                    Time.elapsed_play_time_modified_sec - \
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
            for tile_map in tilemaps:
                if tile_map == surface_state.touched_tile_map:
                    continue
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
                    surface_state.just_touched_ceiling = false
                    surface_state.touched_side = SurfaceSide.FLOOR
                    surface_state.touched_surface_normal = Geometry.UP
                SurfaceSide.CEILING:
                    surface_state.is_touching_ceiling = true
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
                    LevelConfig.get_friction_for_tile( \
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
func _update_actions(_delta_sec: float) -> void:
    if is_stuck:
        return
    
    _delta_sec *= Time.physics_framerate_multiplier
    
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
        last_jump_input_time = Time.elapsed_play_time_modified_sec
        was_last_jump_input_consumed = false
    
# Updates physics and player states in response to the current actions.
func _process_actions(delta_sec: float) -> void:
    if is_stuck:
        return
    
    delta_sec *= Time.physics_framerate_multiplier
    
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
        
        velocity.y *= WALL_BOUNCE_VERTICAL_BOOST_MULTIPLIER
        velocity.y += WALL_BOUNCE_VERTICAL_BOOST_OFFSET
    
    var is_previous_jump_input_still_consumable := \
            !was_last_jump_input_consumed and \
            last_jump_input_time + \
                    JUMP_ANTICIPATION_FORGIVENESS_THRESHOLD_SEC > \
                    Time.elapsed_play_time_modified_sec
    var is_jump_after_recent_fall_still_consumable := \
            !surface_state.is_touching_a_surface and \
            !surface_state.entered_air_by_jumping and \
            last_floor_departure_time > \
            Time.elapsed_play_time_modified_sec - \
                    JUMP_DELAY_FORGIVENESS_THRESHOLD_SEC
    
    var modified_windiness := windiness * WINDINESS_MULTIPLIER
    
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
        # If the player falls off a wall or ledge, then that's considered the
        # first jump.
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
                modified_windiness, \
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
            MAX_VERTICAL_SPEED, \
            modified_windiness)

# Updates the animation state for the current frame.
func _process_animation() -> void:
    if is_stuck:
        return
    
    _update_player_animation()
    _update_squash_and_stretch()
    _update_effects_animations()

func _update_player_animation() -> void:
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
    
    if surface_state.just_left_floor and \
            surface_state.entered_air_by_jumping:
        if abs(velocity.x) > 1:
            effects_animator.play( \
                    EffectAnimation.JUMP_SIDEWAYS, \
                    surface_state.horizontal_facing_sign)
        else:
            effects_animator.play(EffectAnimation.JUMP_VERTICAL)

func _update_squash_and_stretch() -> void:
    if surface_state.just_left_floor and surface_state.entered_air_by_jumping:
        # Stretch.
        var stretch_duration_sec := \
                STRETCH_DURATION_SEC * Time.physics_framerate_multiplier
        var duration_a := stretch_duration_sec * 0.25
        var duration_b := stretch_duration_sec - duration_a
        stretch_tween.interpolate_property( \
                $TuberAnimator, \
                "scale_multiplier", \
                Vector2.ONE, \
                STRETCH_SCALE_MULTIPLIER, \
                duration_a, \
                Tween.TRANS_QUART, \
                Tween.EASE_OUT)
        stretch_tween.interpolate_property( \
                $TuberAnimator, \
                "position", \
                Vector2.ZERO, \
                STRETCH_DISPLACEMENT, \
                duration_a, \
                Tween.TRANS_QUART, \
                Tween.EASE_OUT)
        stretch_tween.interpolate_property( \
                $TuberAnimator, \
                "scale_multiplier", \
                STRETCH_SCALE_MULTIPLIER, \
                Vector2.ONE, \
                duration_b, \
                Tween.TRANS_QUAD, \
                Tween.EASE_OUT, \
                duration_a)
        stretch_tween.interpolate_property( \
                $TuberAnimator, \
                "position", \
                STRETCH_DISPLACEMENT, \
                Vector2.ZERO, \
                duration_b, \
                Tween.TRANS_QUAD, \
                Tween.EASE_OUT, \
                duration_a)
        stretch_tween.start()
    
    if surface_state.just_left_air and surface_state.is_touching_floor:
        # Squash.
        var squash_duration_sec := \
                SQUASH_DURATION_SEC * Time.physics_framerate_multiplier
        squash_tween.interpolate_property( \
                $TuberAnimator, \
                "scale_multiplier", \
                SQUASH_SCALE_MULTIPLIER, \
                Vector2.ONE, \
                squash_duration_sec, \
                Tween.TRANS_QUART, \
                Tween.EASE_OUT)
        squash_tween.interpolate_property( \
                $TuberAnimator, \
                "position", \
                SQUASH_DISPLACEMENT, \
                Vector2.ZERO, \
                squash_duration_sec, \
                Tween.TRANS_QUART, \
                Tween.EASE_OUT)
        squash_tween.start()

func _update_effects_animations() -> void:
    if surface_state.just_touched_floor:
        effects_animator.play(EffectAnimation.LAND)
    
    if surface_state.just_touched_wall and !surface_state.is_touching_floor:
        effects_animator.play( \
                EffectAnimation.WALL_BOUNCE, \
                -1 if surface_state.is_touching_left_wall else 1)
    
    if surface_state.just_touched_ceiling:
        effects_animator.play(EffectAnimation.CEILING_HIT)
    
    if surface_state.is_touching_floor and velocity.x != 0.0:
        throttled_play_walk_effect.call_func()

func _play_walk_effect() -> void:
    if surface_state.is_touching_floor:
        effects_animator.play(EffectAnimation.WALK)

# Updates sounds for the current frame.
func _process_sounds() -> void:
    if is_stuck:
        return
    
    if just_triggered_jump:
        Audio.play_sound(Sound.JUMP)
    
    if surface_state.just_touched_floor or \
            surface_state.just_touched_ceiling:
        Audio.play_sound(Sound.LAND)
    
    if surface_state.just_touched_wall:
        Audio.play_sound(Sound.BOUNCE)
    
    if Input.is_action_just_pressed("jump"):
        Audio.play_sound(Sound.JUMP_INPUT)
    
    if Input.is_action_just_pressed("move_left") or \
            Input.is_action_just_pressed("move_right"):
        Audio.play_sound(Sound.SIDEWAYS_INPUT)
    
    if surface_state.is_touching_floor and velocity.x != 0.0:
        throttled_play_walk_sound.call_func()

func _play_walk_sound() -> void:
    if surface_state.is_touching_floor:
        var sound: int = LevelConfig.get_walk_sound_for_tile( \
                surface_state.touched_tile_map.tile_set, \
                surface_state.touched_tile_map_cell)
        Audio.play_sound(sound)

func _set_is_stuck(value: bool) -> void:
    var was_stuck := is_stuck
    is_stuck = value
    if is_stuck != was_stuck:
        if is_stuck:
            animator.stuck()
        else:
            animator.jump_fall()

func _get_is_stuck() -> bool:
    return is_stuck

func update_light( \
        peep_hole_size: Vector2, \
        light_energy: float) -> void:
    $Light2D.scale = \
            (peep_hole_size / LIGHT_IMAGE_SIZE) * \
            PLAYER_LIGHT_TO_PEEP_HOLE_SIZE_RATIO
    $Light2D.energy = light_energy

func get_spawn_position_for_tier( \
        tier: Tier, \
        is_base_tier: bool) -> Vector2:
    var spawn_position := tier.spawn_position
    spawn_position.y -= Constants.PLAYER_HALF_HEIGHT_DEFAULT
    spawn_position += PLAYER_STUCK_ANIMATION_CENTER_OFFSET
    return spawn_position
