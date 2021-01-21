extends Node

static func error( \
        message := "An error occurred", \
        should_assert := true):
    push_error("ERROR: %s" % message)
    if should_assert:
         assert(false)

static func warning(message := "An warning occurred"):
    push_warning("WARNING: %s" % message)

# TODO: Replace this with any built-in feature whenever it exists
#       (https://github.com/godotengine/godot/issues/4715).
static func subarray( \
        array: Array, \
        start: int, \
        length := -1) -> Array:
    if length < 0:
        length = array.size() - start
    var result := []
    result.resize(length)
    for i in range(length):
        result[i] = array[start + i]
    return result

# TODO: Replace this with any built-in feature whenever it exists
#       (https://github.com/godotengine/godot/issues/4715).
static func sub_pool_vector2_array( \
        array: PoolVector2Array, \
        start: int, \
        length := -1) -> PoolVector2Array:
    if length < 0:
        length = array.size() - start
    var result := PoolVector2Array()
    result.resize(length)
    for i in range(length):
        result[i] = array[start + i]
    return result

# TODO: Replace this with any built-in feature whenever it exists
#       (https://github.com/godotengine/godot/issues/4715).
static func concat( \
        result: Array, \
        other: Array) -> void:
    var old_result_size := result.size()
    var other_size := other.size()
    result.resize(old_result_size + other_size)
    for i in range(other_size):
        result[old_result_size + i] = other[i]

static func join( \
        array, \
        delimiter := ",") -> String:
    assert(array is Array or array is PoolStringArray)
    var count: int = array.size()
    var result := ""
    for index in range(array.size() - 1):
        result += array[index] + delimiter
    if count > 0:
        result += array[count - 1]
    return result

static func array_to_set(array: Array) -> Dictionary:
    var set := {}
    for element in array:
        set[element] = element
    return set

static func translate_polyline( \
        vertices: PoolVector2Array, \
        translation: Vector2) \
        -> PoolVector2Array:
    var result := PoolVector2Array()
    result.resize(vertices.size())
    for i in range(vertices.size()):
        result[i] = vertices[i] + translation
    return result

static func get_children_by_type( \
        parent: Node, \
        type, \
        recursive := false) -> Array:
    var result = []
    for child in parent.get_children():
        if child is type:
            result.push_back(child)
        if recursive:
            concat( \
                    result, \
                    get_children_by_type( \
                            child, \
                            type, \
                            recursive))
    return result

static func get_child_by_type( \
        parent: Node, \
        type, \
        recursive := false) -> Node:
    var children := get_children_by_type(parent, type, recursive)
    assert(children.size() == 1)
    return children[0]

static func get_which_wall_collided_for_body(body: KinematicBody2D) -> int:
    if body.is_on_wall():
        for i in range(body.get_slide_count()):
            var collision := body.get_slide_collision(i)
            var side := get_which_surface_side_collided(collision)
            if side == SurfaceSide.LEFT_WALL or side == SurfaceSide.RIGHT_WALL:
                return side
    return SurfaceSide.NONE

static func get_which_surface_side_collided( \
        collision: KinematicCollision2D) -> int:
    if abs(collision.normal.angle_to(Geometry.UP)) <= \
            Geometry.FLOOR_MAX_ANGLE:
        return SurfaceSide.FLOOR
    elif abs(collision.normal.angle_to(Geometry.DOWN)) <= \
            Geometry.FLOOR_MAX_ANGLE:
        return SurfaceSide.CEILING
    elif collision.normal.x > 0:
        return SurfaceSide.LEFT_WALL
    else:
        return SurfaceSide.RIGHT_WALL

static func get_floor_friction_multiplier(body: KinematicBody2D) -> float:
    var collision := _get_floor_collision(body)
    # Collision friction is a property of the TileMap node.
    if collision != null and collision.collider.collision_friction != null:
        return collision.collider.collision_friction
    return 0.0

static func _get_floor_collision( \
        body: KinematicBody2D) -> KinematicCollision2D:
    if body.is_on_floor():
        for i in range(body.get_slide_count()):
            var collision := body.get_slide_collision(i)
            if abs(collision.normal.angle_to(Geometry.UP)) <= \
                    Geometry.FLOOR_MAX_ANGLE:
                return collision
    return null

static func add_scene( \
        parent: Node, \
        resource_path: String, \
        is_attached := true, \
        is_visible := true) -> Node:
    var scene := load(resource_path)
    var node: Node = scene.instance()
    if node is CanvasItem:
        node.visible = is_visible
    if is_attached:
        parent.add_child(node)
    return node

static func update_velocity_in_air( \
        velocity: Vector2, \
        delta_sec: float, \
        is_pressing_jump: bool, \
        is_first_jump: bool, \
        horizontal_acceleration_sign: int, \
        in_air_horizontal_acceleration: float, \
        in_air_horizontal_deceleration: float, \
        windiness: Vector2, \
        slow_rise_gravity_multiplier: float, \
        rise_double_jump_gravity_multiplier: float, \
        gravity_fast_fall: float) -> Vector2:
    var is_rising_from_jump := velocity.y < 0 and is_pressing_jump
    
    # Make gravity stronger when falling. This creates a more satisfying jump.
    # Similarly, make gravity stronger for double jumps.
    var gravity_multiplier := \
            1.0 if \
            !is_rising_from_jump else \
            (slow_rise_gravity_multiplier if \
            is_first_jump else \
            rise_double_jump_gravity_multiplier)
    
    # Vertical movement.
    velocity.y += \
            delta_sec * \
            gravity_fast_fall * \
            gravity_multiplier
    velocity.y += \
            delta_sec * \
            windiness.y
    
    velocity.x += \
            delta_sec * \
            windiness.x
    
    # Horizontal movement.
    if horizontal_acceleration_sign != 0.0:
        # Accelerate.
        velocity.x += \
                delta_sec * \
                in_air_horizontal_acceleration * \
                horizontal_acceleration_sign
    else:
        # Decelerate.
        var previous_horizontal_movement_sign := \
                1.0 if \
                velocity.x > 0 else \
                (-1.0 if \
                velocity.x < 0 else \
                0.0)
        velocity.x += \
                delta_sec * \
                in_air_horizontal_deceleration * \
                -previous_horizontal_movement_sign
        var next_horizontal_movement_sign := \
                1.0 if \
                velocity.x > 0 else \
                (-1.0 if \
                velocity.x < 0 else \
                0.0)
        # Don't allow deceleration to cause movement in the opposite direction.
        if previous_horizontal_movement_sign != next_horizontal_movement_sign:
            velocity.x = 0.0
    
    return velocity

const WINDINESS_VELOCITY_THRESHOLD_MULTIPLIER := 0.1

static func cap_velocity( \
        velocity: Vector2, \
        caps_min_horizontal_speed: bool, \
        min_horizontal_speed: float, \
        max_horizontal_speed: float, \
        min_vertical_speed: float, \
        max_vertical_speed: float, \
        windiness: Vector2) -> Vector2:
    var windiness_horizontal_velocity_threshold_offset := \
            max_horizontal_speed * \
            windiness.x * \
            WINDINESS_VELOCITY_THRESHOLD_MULTIPLIER
    var windiness_vertical_velocity_threshold_offset := \
            max_vertical_speed * \
            windiness.y * \
            WINDINESS_VELOCITY_THRESHOLD_MULTIPLIER
    
    var min_horizontal_velocity: float
    var max_horizontal_velocity: float
    if windiness.x < 0:
        min_horizontal_velocity = \
                -max_horizontal_speed + \
                windiness_horizontal_velocity_threshold_offset
        max_horizontal_velocity = max_horizontal_speed
    else:
        min_horizontal_velocity = -max_horizontal_speed
        max_horizontal_velocity = \
                max_horizontal_speed + \
                windiness_horizontal_velocity_threshold_offset
    
    var min_vertical_velocity: float
    var max_vertical_velocity: float
    if windiness.y < 0:
        min_vertical_velocity = \
                -max_vertical_speed + \
                windiness_vertical_velocity_threshold_offset
        max_vertical_velocity = max_vertical_speed
    else:
        min_vertical_velocity = -max_vertical_speed
        max_vertical_velocity = \
                max_vertical_speed + \
                windiness_vertical_velocity_threshold_offset
    
    # Cap horizontal speed at a max value.
    velocity.x = clamp( \
            velocity.x, \
            min_horizontal_velocity, \
            max_horizontal_velocity)
    
    # Kill horizontal speed below a min value.
    if caps_min_horizontal_speed and \
            velocity.x > -min_horizontal_speed and \
            velocity.x < min_horizontal_speed:
        velocity.x = 0
    
    # Cap vertical speed at a max value.
    velocity.y = clamp( \
            velocity.y, \
            min_vertical_velocity, \
            max_vertical_velocity)
    
    # Kill vertical speed below a min value.
    if velocity.y > -min_vertical_speed and \
            velocity.y < min_vertical_speed:
        velocity.y = 0
    
    return velocity

static func ease_name_to_param(name: String) -> float:
    match name:
        "linear":
            return 1.0
        "ease_in":
            return 2.4
        "ease_in_strong":
            return 4.8
        "ease_in_weak":
            return 1.6
        "ease_out":
            return 0.4
        "ease_out_strong":
            return 0.2
        "ease_out_weak":
            return 0.6
        "ease_in_out":
            return -2.4
        "ease_in_out_strong":
            return -4.8
        "ease_in_out_weak":
            return -1.8
        _:
            Utils.error()
            return INF

static func ease_by_name( \
        progress: float, \
        ease_name: String) -> float:
    return ease(progress, ease_name_to_param(ease_name))

static func get_is_android_device() -> bool:
    return OS.get_name() == "Android"

static func get_is_ios_device() -> bool:
    return OS.get_name() == "iOS"

static func get_is_browser() -> bool:
    return OS.get_name() == "HTML5"

static func get_is_windows_device() -> bool:
    return OS.get_name() == "Windows"

static func get_is_mac_device() -> bool:
    return OS.get_name() == "OSX"

static func get_is_mobile_device() -> bool:
    return get_is_android_device() or get_is_ios_device()

static func get_model_name() -> String:
    return IosModelNames.get_model_name() if \
        get_is_ios_device() else \
        OS.get_model_name()

func get_screen_scale() -> float:
    # NOTE: OS.get_screen_scale() is only implemented for MacOS, so it's
    #       useless.
    if get_is_mobile_device():
        if OS.window_size.x < OS.window_size.y:
            return OS.window_size.x / get_viewport().size.x
        else:
            return OS.window_size.y / get_viewport().size.y
    elif get_is_mac_device():
        return OS.get_screen_scale()
    else:
        return 1.0

# This does not take into account the screen scale. Node.get_viewport().size
# likely returns a smaller number than OS.window_size, because of screen scale.
static func get_screen_ppi() -> int:
    if get_is_ios_device():
        return IosResolutions.get_screen_ppi()
    else:
        return OS.get_screen_dpi()

# This takes into account the screen scale, and should enable accurate
# conversion of event positions from pixels to inches.
# 
# NOTE: This assumes that the viewport takes up the entire screen, which will
#       likely be true only for mobile devices, and is not even guaranteed for
#       them.
func get_viewport_ppi() -> float:
    return get_screen_ppi() / get_screen_scale()

func get_viewport_size_inches() -> Vector2:
    return get_viewport().size / get_viewport_ppi()

func get_viewport_diagonal_inches() -> float:
    return get_viewport_size_inches().length()

func get_viewport_safe_area() -> Rect2:
    var os_safe_area := OS.get_window_safe_area()
    return Rect2( \
            os_safe_area.position / get_screen_scale(), \
            os_safe_area.size / get_screen_scale())

func get_safe_area_margin_top() -> float:
    return Utils.get_viewport_safe_area().position.y

func get_safe_area_margin_bottom() -> float:
    return get_viewport().size.y - Utils.get_viewport_safe_area().end.y

func get_safe_area_margin_left() -> float:
    return Utils.get_viewport_safe_area().position.x

func get_safe_area_margin_right() -> float:
    return get_viewport().size.x - OS.get_window_safe_area().end.x

static func floor_vector(v: Vector2) -> Vector2:
    return Vector2(floor(v.x), floor(v.y))

static func mix( \
        values: Array, \
        weights: Array):
    assert(values.size() == weights.size())
    assert(!values.empty())
    
    var count := values.size()
    
    var weight_sum := 0.0
    for weight in weights:
        weight_sum += weight
    
    var weighted_average
    if values[0] is float or values[0] is int:
        weighted_average = 0.0
    elif values[0] is Vector2:
        weighted_average = Vector2.ZERO
    elif values[0] is Vector3:
        weighted_average = Vector3.ZERO
    else:
        error()
    
    for i in range(count):
        var value = values[i]
        var weight: float = weights[i]
        var normalized_weight := \
                weight / weight_sum if \
                weight_sum > 0.0 else \
                1.0 / count
        weighted_average += value * normalized_weight
    
    return weighted_average

static func mix_colors( \
        colors: Array, \
        weights: Array) -> Color:
    assert(colors.size() == weights.size())
    assert(!colors.empty())
    
    var count := colors.size()
    
    var weight_sum := 0.0
    for weight in weights:
        weight_sum += weight
    
    var h := 0.0
    var s := 0.0
    var v := 0.0
    for i in range(count):
        var color: Color = colors[i]
        var weight: float = weights[i]
        var normalized_weight := \
                weight / weight_sum if \
                weight_sum > 0.0 else \
                1.0 / count
        h += color.h * normalized_weight
        s += color.s * normalized_weight
        v += color.v * normalized_weight
    
    return Color.from_hsv(h, s, v, 1.0)

static func get_datetime_string() -> String:
    var datetime := OS.get_datetime()
    return "%s-%s-%s-%s-%s-%s" % [
        datetime.year,
        datetime.month,
        datetime.day,
        datetime.hour,
        datetime.minute,
        datetime.second,
    ]

func take_screenshot() -> void:
    var directory := Directory.new()
    if !directory.dir_exists("user://screenshots"):
        var status := directory.open("user://")
        if status != OK:
            Utils.error()
            return
        directory.make_dir("screenshots")
    
    var image := get_viewport().get_texture().get_data()
    image.flip_y()
    var path := "user://screenshots/screenshot-%s.png" % get_datetime_string()
    var status := image.save_png(path)
    if status != OK:
        Utils.error()

func clear_directory( \
        path: String, \
        also_deletes_directory := false) -> void:
    # Open directory.
    var directory := Directory.new()
    var status := directory.open(path)
    if status != OK:
        Utils.error()
        return
    
    # Delete children.
    directory.list_dir_begin(true)
    var file_name := directory.get_next()
    while file_name != "":
        if directory.current_is_dir():
            var child_path := \
                    path + file_name if \
                    path.ends_with("/") else \
                    path + "/" + file_name
            clear_directory(child_path, true)
        else:
            status = directory.remove(file_name)
            if status != OK:
                Utils.error("Failed to delete file", false)
        file_name = directory.get_next()
    
    # Delete directory.
    if also_deletes_directory:
        status = directory.remove(path)
        if status != OK:
            Utils.error("Failed to delete directory", false)
