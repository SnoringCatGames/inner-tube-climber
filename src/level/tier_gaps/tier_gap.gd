tool
extends Node2D
class_name TierGap

var configuration_warning := ""

func _ready() -> void:
    var tile_maps := Utils.get_children_by_type( \
            self, \
            TierTileMap)
    if tile_maps.size() > 1:
        configuration_warning = "Must define only one child TierTileMap."
        update_configuration_warning()
    elif tile_maps.size() < 1:
        configuration_warning = "Must define a child TierTileMap."
        update_configuration_warning()

func _get_configuration_warning() -> String:
    return configuration_warning
