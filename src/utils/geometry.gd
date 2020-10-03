extends Node

const UP := Vector2.UP
const DOWN := Vector2.DOWN
const LEFT := Vector2.LEFT
const RIGHT := Vector2.RIGHT
const FLOOR_MAX_ANGLE := PI / 4.0
const GRAVITY := 5000.0
const FLOAT_EPSILON := 0.00001

# Calculates the minimum squared distance between a line segment and a point.
static func get_distance_squared_from_point_to_segment( \
        point: Vector2, \
        segment_a: Vector2, \
        segment_b: Vector2) -> float:
    var closest_point := get_closest_point_on_segment_to_point( \
            point, \
            segment_a, \
            segment_b)
    return point.distance_squared_to(closest_point)

# Calculates the minimum squared distance between a polyline and a point.
static func get_distance_squared_from_point_to_polyline( \
        point: Vector2, \
        polyline: PoolVector2Array) -> float:
    var closest_point := get_closest_point_on_polyline_to_point( \
            point, \
            polyline)
    return point.distance_squared_to(closest_point)

# Calculates the minimum squared distance between two NON-INTERSECTING line
# segments.
static func get_distance_squared_between_non_intersecting_segments( \
        segment_1_a: Vector2, \
        segment_1_b: Vector2, \
        segment_2_a: Vector2, \
        segment_2_b: Vector2) -> float:
    var closest_on_2_to_1_a = get_closest_point_on_segment_to_point( \
            segment_1_a, \
            segment_2_a, \
            segment_2_b)
    var closest_on_2_to_1_b = get_closest_point_on_segment_to_point( \
            segment_1_b, \
            segment_2_a, \
            segment_2_b)
    var closest_on_1_to_2_a = get_closest_point_on_segment_to_point( \
            segment_2_a, \
            segment_1_a, \
            segment_1_b)
    var closest_on_1_to_2_b = get_closest_point_on_segment_to_point( \
            segment_2_a, \
            segment_1_a, \
            segment_1_b)
    
    var distance_squared_from_2_to_1_a = \
            closest_on_2_to_1_a.distance_squared_to(segment_1_a)
    var distance_squared_from_2_to_1_b = \
            closest_on_2_to_1_b.distance_squared_to(segment_1_b)
    var distance_squared_from_1_to_2_a = \
            closest_on_1_to_2_a.distance_squared_to(segment_2_a)
    var distance_squared_from_1_to_2_b = \
            closest_on_1_to_2_b.distance_squared_to(segment_2_b)
    
    return min(min(distance_squared_from_2_to_1_a, \
                    distance_squared_from_2_to_1_b), \
            min(distance_squared_from_1_to_2_a, \
                    distance_squared_from_1_to_2_b))

# Calculates the closest position on a line segment to a point.
static func get_closest_point_on_segment_to_point( \
        point: Vector2, \
        segment_a: Vector2, \
        segment_b: Vector2) -> Vector2:
    var v := segment_b - segment_a
    var u := point - segment_a
    var uv: float = u.dot(v)
    var vv: float = v.dot(v)
    
    if uv <= 0.0:
        # The projection of the point lies before the first point in the
        # segment.
        return segment_a
    elif vv <= uv:
        # The projection of the point lies after the last point in the segment.
        return segment_b
    else:
        # The projection of the point lies within the bounds of the segment.
        var t := uv / vv
        return segment_a + t * v

static func get_closest_point_on_polyline_to_point( \
        point: Vector2, \
        polyline: PoolVector2Array) -> Vector2:
    if polyline.size() == 1:
        return polyline[0]
    
    var closest_point := get_closest_point_on_segment_to_point( \
            point, \
            polyline[0], \
            polyline[1])
    var closest_distance_squared := point.distance_squared_to(closest_point)
    
    var current_point: Vector2
    var current_distance_squared: float
    for i in range(1, polyline.size() - 1):
        current_point = get_closest_point_on_segment_to_point( \
                point, \
                polyline[i], \
                polyline[i + 1])
        current_distance_squared = point.distance_squared_to(current_point)
        if current_distance_squared < closest_distance_squared:
            closest_distance_squared = current_distance_squared
            closest_point = current_point
    
    return closest_point

static func get_closest_point_on_polyline_to_polyline( \
        a: PoolVector2Array, \
        b: PoolVector2Array) -> Vector2:
    if a.size() == 1:
        return a[0]
    
    var closest_point: Vector2
    var closest_distance_squared: float = INF
    
    var current_point: Vector2
    var current_distance_squared: float
    for vertex_b in b:
        current_point = get_closest_point_on_polyline_to_point(vertex_b, a)
        current_distance_squared = vertex_b.distance_squared_to(current_point)
        if current_distance_squared < closest_distance_squared:
            closest_distance_squared = current_distance_squared
            closest_point = current_point
    
    return closest_point

# Calculates the point of intersection between two line segments. If the
# segments don't intersect, this returns a Vector2 with values of INFINITY.
static func get_intersection_of_segments( \
        segment_1_a: Vector2, \
        segment_1_b: Vector2, \
        segment_2_a: Vector2, \
        segment_2_b: Vector2) -> Vector2:
    var r := segment_1_b - segment_1_a
    var s := segment_2_b - segment_2_a
    
    var u_numerator := (segment_2_a - segment_1_a).cross(r)
    var denominator := r.cross(s)
    
    if u_numerator == 0 and denominator == 0:
        # The segments are collinear.
        var t0_numerator := (segment_2_a - segment_1_a).dot(r)
        var t1_numerator := (segment_1_a - segment_2_a).dot(s)
        if 0 <= t0_numerator and t0_numerator <= r.dot(r) or \
                0 <= t1_numerator and t1_numerator <= s.dot(s):
            # The segments overlap. Return one of the segment endpoints that
            # lies within the overlap region.
            if (segment_1_a.x >= segment_2_a.x and \
                    segment_1_a.x <= segment_2_b.x) or \
                    (segment_1_a.x <= segment_2_a.x and \
                    segment_1_a.x >= segment_2_b.x):
                return segment_1_a
            else:
                return segment_1_b
        else:
            # The segments are disjoint.
            return Vector2.INF
    elif denominator == 0:
        # The segments are parallel.
        return Vector2.INF
    else:
        # The segments are not parallel.
        var u := u_numerator / denominator
        var t := (segment_2_a - segment_1_a).cross(s) / denominator
        if t >= 0 and t <= 1 and u >= 0 and u <= 1:
            # The segments intersect.
            return segment_1_a + t * r
        else:
            # The segments don't touch.
            return Vector2.INF

# Calculates the point of intersection between a line segment and a polyline.
# If the two don't intersect, this returns a Vector2 with values of INFINITY.
static func get_intersection_of_segment_and_polyline( \
        segment_a: Vector2, \
        segment_b: Vector2, \
        vertices: PoolVector2Array) -> Vector2:
    if vertices.size() == 1:
        if do_point_and_segment_intersect( \
                segment_a, \
                segment_b, \
                vertices[0]):
            return vertices[0]
    else:
        var intersection: Vector2
        for i in range(vertices.size() - 1):
            intersection = get_intersection_of_segments( \
                    segment_a, \
                    segment_b, \
                    vertices[i], \
                    vertices[i + 1])
            if intersection != Vector2.INF:
                return intersection
    return Vector2.INF

static func is_point_in_triangle( \
        point: Vector2, \
        a: Vector2, \
        b: Vector2, \
        c: Vector2) -> bool:
    # Uses the barycentric approach.
    
    var ac := c - a
    var ab := b - a
    var ap := point - a
    
    var dot_ac_ac: float = ac.dot(ac)
    var dot_ac_ab: float = ac.dot(ab)
    var dot_ac_ap: float = ac.dot(ap)
    var dot_ab_ab: float = ab.dot(ab)
    var dot_ab_ap: float = ab.dot(ap)
    
    # The barycentric coordinates.
    var inverse_denominator := \
            1 / (dot_ac_ac * dot_ab_ab - dot_ac_ab * dot_ac_ab)
    var u := (dot_ab_ab * dot_ac_ap - dot_ac_ab * dot_ab_ap) * \
            inverse_denominator
    var v := (dot_ac_ac * dot_ab_ap - dot_ac_ab * dot_ac_ap) * \
            inverse_denominator
    
    return u >= 0 and v >= 0 and u + v < 1

static func do_segment_and_triangle_intersect( \
        segment_a: Vector2, \
        segment_b: Vector2, \
        triangle_a: Vector2, \
        triangle_b: Vector2, \
        triangle_c: Vector2) -> bool:
    return \
            get_intersection_of_segments( \
                    segment_a, \
                    segment_b, \
                    triangle_a, \
                    triangle_b) != Vector2.INF or \
            get_intersection_of_segments( \
                    segment_a, \
                    segment_b, \
                    triangle_a, \
                    triangle_c) != Vector2.INF or \
            get_intersection_of_segments( \
                    segment_a, \
                    segment_b, \
                    triangle_b, \
                    triangle_c) != Vector2.INF or \
            is_point_in_triangle( \
                    segment_a, \
                    triangle_a, \
                    triangle_b, \
                    triangle_c)

# - Assumes that the polygon's closing segment is implied;
#   i.e., polygon.last != polygon.first.
# - Assumes that polygon.size() > 1.
# - Assumes that segment_a != segment_b.
# 
# -----------------------------------------------------------------------------
# Based on the "parametric line-clipping" approach described by Dan Sunday at
# http://geomalgorithms.com/a13-_intersect-4.html.
# 
# Copyright 2001 softSurfer, 2012 Dan Sunday
# This code may be freely used and modified for any purpose
# providing that this copyright notice is included with it.
# SoftSurfer makes no warranty for this code, and cannot be held
# liable for any real or imagined damage resulting from its use.
# Users of this code must verify correctness for their application.
# -----------------------------------------------------------------------------
static func do_segment_and_polygon_intersect( \
        segment_a: Vector2, \
        segment_b: Vector2, \
        polygon: Array) -> bool:
    assert(polygon[0] == polygon[polygon.size() - 1])
    
    var count = polygon.size()
    var segment_diff := segment_b - segment_a
    var polygon_segment: Vector2
    var p_to_a: Vector2
    
    var t_entering := 0.0
    var t_leaving := 1.0
    var t: float
    var n: float
    var d: float
    
    for i in range(count - 1):
        polygon_segment = polygon[i + 1] - polygon[i]
        p_to_a = segment_a - polygon[i]
        n = polygon_segment.x * p_to_a.y - polygon_segment.y * p_to_a.x
        d = polygon_segment.y * segment_diff.x - \
                polygon_segment.x * segment_diff.y
        
        if abs(d) < Geometry.FLOAT_EPSILON:
            if n < 0:
                return false
            else:
                continue
        t = n / d
        if d < 0:
            if t > t_entering:
                t_entering = t
                if t_entering > t_leaving:
                    return false
        else:
            if t < t_leaving:
                t_leaving = t
                if t_leaving < t_entering:
                    return false
    
    # Possible point of intersection 1: segment_a + t_entering * segment_diff
    # Possible point of intersection 2: segment_a + t_leaving * segment_diff
    
    return true

static func do_polyline_and_triangle_intersect( \
        vertices: PoolVector2Array, \
        triangle_a: Vector2, \
        triangle_b: Vector2, \
        triangle_c: Vector2) -> bool:
    var segment_a: Vector2
    var segment_b: Vector2
    for i in range(vertices.size() - 1):
        segment_a = vertices[i]
        segment_b = vertices[i + 1]
        if do_segment_and_triangle_intersect( \
                segment_a, \
                segment_b, \
                triangle_a, \
                triangle_b, \
                triangle_c):
            return true
    return false

static func do_polyline_and_polygon_intersect( \
        vertices: PoolVector2Array, \
        polygon: Array) -> bool:
    var segment_a: Vector2
    var segment_b: Vector2
    for i in range(vertices.size() - 1):
        segment_a = vertices[i]
        segment_b = vertices[i + 1]
        if do_segment_and_polygon_intersect( \
                segment_a, \
                segment_b, \
                polygon):
            return true
    return false

static func are_floats_equal_with_epsilon( \
        a: float, \
        b: float, \
        epsilon := FLOAT_EPSILON) -> bool:
    var diff = b - a
    return -epsilon < diff and diff < epsilon

static func are_points_equal_with_epsilon( \
        a: Vector2, \
        b: Vector2, \
        epsilon := FLOAT_EPSILON) -> bool:
    var x_diff = b.x - a.x
    var y_diff = b.y - a.y
    return -epsilon < x_diff and x_diff < epsilon and \
            -epsilon < y_diff and y_diff < epsilon

static func is_float_gte_with_epsilon( \
        a: float, \
        b: float, \
        epsilon := FLOAT_EPSILON) -> bool:
    var diff = b - a
    return a >= b or (-epsilon < diff and diff < epsilon)

static func is_float_lte_with_epsilon( \
        a: float, \
        b: float, \
        epsilon := FLOAT_EPSILON) -> bool:
    var diff = b - a
    return a <= b or (-epsilon < diff and diff < epsilon)

# Determine whether the points of the polygon are defined in a clockwise
# direction. This uses the shoelace formula.
static func is_polygon_clockwise(vertices: Array) -> bool:
    var vertex_count := vertices.size()
    var sum := 0.0
    var v1: Vector2 = vertices[vertex_count - 1]
    var v2: Vector2 = vertices[0]
    sum += (v2.x - v1.x) * (v2.y + v1.y)
    for i in range(vertex_count - 1):
        v1 = vertices[i]
        v2 = vertices[i + 1]
        sum += (v2.x - v1.x) * (v2.y + v1.y)
    return sum < 0

static func are_three_points_clockwise( \
        a: Vector2, \
        b: Vector2, \
        c: Vector2) -> bool:
    var result := (a.y - b.y) * (c.x - a.x) - (a.x - b.x) * (c.y - a.y)
    return result > 0

static func are_points_collinear( \
        p1: Vector2, \
        p2: Vector2, \
        p3: Vector2) -> bool:
    return abs((p2.x - p1.x) * (p3.y - p1.y) - \
            (p3.x - p1.x) * (p2.y - p1.y)) < FLOAT_EPSILON

static func do_point_and_segment_intersect( \
        point: Vector2, \
        segment_a: Vector2, \
        segment_b: Vector2) -> bool:
    return are_points_collinear( \
            point, \
            segment_a, \
            segment_b) and \
            ((point.x <= segment_a.x and point.x >= segment_b.x) or \
            (point.x >= segment_a.x and point.x <= segment_b.x))

static func get_bounding_box_for_points(points: Array) -> Rect2:
    assert(points.size() > 0)
    var bounding_box := Rect2(points[0], Vector2.ZERO)
    for i in range(1, points.size()):
        bounding_box = bounding_box.expand(points[i])
    return bounding_box

static func distance_squared_from_point_to_rect( \
        point: Vector2, \
        rect: Rect2) -> float:
    var rect_min := rect.position
    var rect_max := rect.end
    
    if point.x < rect_min.x:
        if point.y < rect_min.y:
            return point.distance_squared_to(rect_min)
        elif point.y > rect_max.y:
            return point.distance_squared_to(Vector2(rect_min.x, rect_max.y))
        else:
            var distance = rect_min.x - point.x
            return distance * distance
    elif point.x > rect_max.x:
        if point.y < rect_min.y:
            return point.distance_squared_to(Vector2(rect_max.x, rect_min.y))
        elif point.y > rect_max.y:
            return point.distance_squared_to(rect_max)
        else:
            var distance = point.x - rect_max.x
            return distance * distance
    else:
        if point.y < rect_min.y:
            var distance = rect_min.y - point.y
            return distance * distance
        elif point.y > rect_max.y:
            var distance = point.y - rect_max.y
            return distance * distance
        else:
            return 0.0

# The build-in TileMap.world_to_map generates incorrect results around cell
# boundaries, so we use a custom utility.
static func world_to_tile_map( \
        position: Vector2, \
        tile_map: TileMap) -> Vector2:
    var cell_size_world_coord := tile_map.cell_size
    var position_map_coord := position / cell_size_world_coord
    position_map_coord = Vector2( \
            floor(position_map_coord.x), \
            floor(position_map_coord.y))
    return position_map_coord

# Calculates the TileMap (grid-based) coordinates of the given position,
# relative to the origin of the TileMap's bounding box.
static func get_tile_map_index_from_world_coord( \
        position: Vector2, \
        tile_map: TileMap) -> int:
    var position_grid_coord = world_to_tile_map(position, tile_map)
    return get_tile_map_index_from_grid_coord(position_grid_coord, tile_map)

# Calculates the TileMap (grid-based) coordinates of the given position,
# relative to the origin of the TileMap's bounding box.
static func get_tile_map_index_from_grid_coord( \
        position: Vector2, \
        tile_map: TileMap) -> int:
    var used_rect := tile_map.get_used_rect()
    var tile_map_start := used_rect.position
    var tile_map_width: int = used_rect.size.x
    var tile_map_position: Vector2 = position - tile_map_start
    return (tile_map_position.y * tile_map_width + tile_map_position.x) as int

static func get_tile_map_bounds_in_world_coordinates( \
        tile_map: TileMap) -> Rect2:
    var used_rect := tile_map.get_used_rect()
    var cell_size := tile_map.cell_size
    return Rect2( \
            used_rect.position.x * cell_size.x, \
            used_rect.position.y * cell_size.y, \
            used_rect.size.x * cell_size.x, \
            used_rect.size.y * cell_size.y)

static func do_shapes_match( \
        a: Shape2D, \
        b: Shape2D) -> bool:
    if a is CircleShape2D:
        return b is CircleShape2D and \
                a.radius == b.radius
    elif a is CapsuleShape2D:
        return b is CapsuleShape2D and \
                a.radius == b.radius and \
                a.height == b.height
    elif a is RectangleShape2D:
        return b is RectangleShape2D and \
                a.extents == b.extents
    else:
        Utils.error( \
                "Invalid Shape2D provided for do_shapes_match: %s. The " + \
                "supported shapes are: CircleShape2D, CapsuleShape2D, " + \
                "RectangleShape2D." % a)
        return false

# The given rotation must be either 0 or PI.
static func calculate_half_width_height( \
        shape: Shape2D, \
        rotation: float) -> Vector2:
    var is_rotated_90_degrees = abs(fmod(rotation + PI * 2, PI) - PI / 2.0) < \
            Geometry.FLOAT_EPSILON
    
    # Ensure that collision boundaries are only ever axially aligned.
    assert(is_rotated_90_degrees or abs(rotation) < Geometry.FLOAT_EPSILON)
    
    var half_width_height: Vector2
    if shape is CircleShape2D:
        half_width_height = Vector2( \
                shape.radius, \
                shape.radius)
    elif shape is CapsuleShape2D:
        half_width_height = Vector2( \
                shape.radius, \
                shape.radius + shape.height / 2.0)
    elif shape is RectangleShape2D:
        half_width_height = shape.extents
    else:
        Utils.error( \
                "Invalid Shape2D provided to calculate_half_width_height: " + \
                "%s. The upported shapes are: CircleShape2D, " + \
                "CapsuleShape2D, RectangleShape2D." % shape)
    
    if is_rotated_90_degrees:
        var swap := half_width_height.x
        half_width_height.x = half_width_height.y
        half_width_height.y = swap
        
    return half_width_height

static func calculate_manhattan_distance( \
        a: Vector2, \
        b: Vector2) -> float:
    return abs(b.x - a.x) + abs(b.y - a.y)
