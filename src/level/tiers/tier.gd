tool
extends Node2D
class_name Tier

# NOTE: Keep in-sync with the values in openness_type.gd.
enum OpennessType {
    UNKNOWN,
    WALLED,
    WALLED_LEFT,
    WALLED_RIGHT,
    OPEN_WITHOUT_HORIZONTAL_PAN,
    OPEN_WITH_HORIZONTAL_PAN,
}

export(OpennessType) var openness_type := OpennessType.UNKNOWN

var configuration_warning := ""

func _ready() -> void:
    var tile_maps := Utils.get_children_by_type( \
            self, \
            TierTileMap)
    var spawn_positions := Utils.get_children_by_type( \
            self, \
            PlayerSpawnPosition)
    if tile_maps.size() > 1:
        configuration_warning = "Must define only one child TierTileMap."
        update_configuration_warning()
    elif tile_maps.size() < 1:
        configuration_warning = "Must define a child TierTileMap."
        update_configuration_warning()
    elif spawn_positions.size() > 1:
        configuration_warning = \
                "Must define only one child PlayerSpawnPosition."
        update_configuration_warning()
    elif spawn_positions.size() < 1:
        configuration_warning = "Must define a child PlayerSpawnPosition."
        update_configuration_warning()

func get_player_spawn_position() -> Vector2:
    var spawn_position: PlayerSpawnPosition = Utils.get_child_by_type( \
            self, \
            PlayerSpawnPosition)
    return spawn_position.position

func _get_configuration_warning() -> String:
    return configuration_warning
