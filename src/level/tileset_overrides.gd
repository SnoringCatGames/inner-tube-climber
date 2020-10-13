tool
extends TileSet
class_name TilesetOverrides

# These IDs are found within the .tres file. There will be a line like
# `0/name = "wall_tile"` for each "tile" defined in the TileSet. The number at
# the start of this line is the ID.
var WALL_TILE_ID: int = 0
var ICE_WALL_TILE_ID: int = 1
var SNOW_PLATFORM_TILE_ID: int = 2
var ICE_PLATFORM_TILE_ID: int = 3

func _is_tile_bound( \
        drawn_id: int, \
        neighbor_id: int) -> bool:
    if neighbor_id == TileMap.INVALID_CELL:
        return false
    
    match drawn_id:
        TileMap.INVALID_CELL:
            Utils.error()
            return false
        WALL_TILE_ID, \
        ICE_WALL_TILE_ID:
            return neighbor_id == WALL_TILE_ID or \
                    neighbor_id == ICE_WALL_TILE_ID
            return neighbor_id == WALL_TILE_ID or \
                    neighbor_id == ICE_WALL_TILE_ID
        SNOW_PLATFORM_TILE_ID:
            return neighbor_id == SNOW_PLATFORM_TILE_ID or \
                    neighbor_id == WALL_TILE_ID or \
                    neighbor_id == ICE_WALL_TILE_ID
        ICE_PLATFORM_TILE_ID:
            return neighbor_id == ICE_PLATFORM_TILE_ID or \
                    neighbor_id == WALL_TILE_ID or \
                    neighbor_id == ICE_WALL_TILE_ID
        _:
            Utils.error()
            return false
