tool
extends TileSet
class_name TilesetOverrides

const WALL_TILE_NAME := "wall_tile"
const SNOW_PLATFORM_TILE_NAME := "snow_platform_tile"
const ICE_PLATFORM_TILE_NAME := "ice_platform_tile"

var WALL_TILE_ID := find_tile_by_name(WALL_TILE_NAME)
var SNOW_PLATFORM_TILE_ID := find_tile_by_name(SNOW_PLATFORM_TILE_NAME)
var ICE_PLATFORM_TILE_ID := find_tile_by_name(ICE_PLATFORM_TILE_NAME)

func _is_tile_bound( \
        drawn_id: int, \
        neighbor_id: int) -> bool:
    match drawn_id:
        WALL_TILE_ID:
            return neighbor_id == WALL_TILE_ID
        SNOW_PLATFORM_TILE_ID:
            return neighbor_id == SNOW_PLATFORM_TILE_ID or \
                    neighbor_id == WALL_TILE_ID
        ICE_PLATFORM_TILE_ID:
            return neighbor_id == ICE_PLATFORM_TILE_ID or \
                    neighbor_id == WALL_TILE_ID
        _:
            Utils.error()
            return false
