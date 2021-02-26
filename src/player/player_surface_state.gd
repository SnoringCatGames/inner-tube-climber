extends Reference
class_name PlayerSurfaceState

var horizontal_facing_sign := 1
var horizontal_acceleration_sign := 0

var collision_count := 0

var is_touching_floor := false
var is_touching_ceiling := false
var is_touching_wall := false
var is_touching_left_wall := false
var is_touching_right_wall := false
var is_touching_a_surface := false

var just_touched_floor := false
var just_left_floor := false
var just_touched_ceiling := false
var just_left_ceiling := false
var just_touched_wall := false
var just_left_left_wall := false
var just_left_right_wall := false
var just_left_wall := false
var just_bounced_off_wall := false
var just_entered_air := false
var just_left_air := false

var touched_side := SurfaceSide.NONE
var touched_surface_normal := Vector2.INF

var touch_position := Vector2.INF
var touched_tile_map: TileMap = null
var touch_position_tile_map_coord := Vector2.INF
var touched_tile_map_cell := TileMap.INVALID_CELL
var friction := INF
var collision_tile_map_coord_result := CollisionTileMapCoordResult.new()

var just_changed_touch_position := false
var just_changed_tile_map := false
var just_changed_tile_map_coord := false

var toward_wall_sign := 0
var entered_air_by_jumping := false
