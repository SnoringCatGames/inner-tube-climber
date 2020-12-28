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

func sync_position_to_previous_tier(previous_tier: Tier) -> void:
    self.position = \
            previous_tier.tier_end_position + \
            Vector2(0.0, Constants.CELL_SIZE.y)
