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
    if Engine.editor_hint:
        var tile_maps := Utils.get_children_by_type( \
                self, \
                TierTileMap)
        var tier_starts := Utils.get_children_by_type( \
                self, \
                TierStart)
        var tier_ends := Utils.get_children_by_type( \
                self, \
                TierEnd)
        if tile_maps.size() > 1:
            configuration_warning = "Must define only one child TierTileMap."
            update_configuration_warning()
        elif tile_maps.size() < 1:
            configuration_warning = "Must define a child TierTileMap."
            update_configuration_warning()
        elif tier_starts.size() > 1:
            configuration_warning = "Must define only one child TierStart."
            update_configuration_warning()
        elif tier_starts.size() < 1:
            configuration_warning = "Must define a child TierStart."
            update_configuration_warning()
        # FIXME: ----------------------------------------------
#        elif tier_ends.size() > 1:
#            configuration_warning = "Must define only one child TierEnd."
#            update_configuration_warning()
#        elif tier_ends.size() < 1:
#            configuration_warning = "Must define a child TierEnd."
#            update_configuration_warning()

func get_spawn_position() -> Vector2:
    var tier_start: TierStart = Utils.get_child_by_type( \
            self, \
            TierStart)
    return tier_start.position + tier_start.spawn_position

func _get_configuration_warning() -> String:
    return configuration_warning
