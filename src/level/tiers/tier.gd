tool
extends Node2D
class_name Tier

const TIER_RATIO_SIGN_RESOURCE_PATH := \
        "res://src/level/tier_ratio_sign/tier_ratio_sign.tscn"
const TIER_START_ICICLE_FALL_ANIMATOR_RESOURCE_PATH := \
        "res://src/level/tier_start_icicle_fall_animator.tscn"

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
export var is_base_tier := false

var tier_start_position: Vector2 setget ,_get_tier_start_position
var tier_end_position: Vector2 setget ,_get_tier_end_position
var spawn_position: Vector2 setget ,_get_spawn_position
var size: Vector2 setget ,_get_size
var windiness: Vector2 setget _set_windiness

var configuration_warning := ""

var tier_start: TierStart
var tier_end: TierEnd

var tier_ratio_sign: TierRatioSign
var icicle_fall_animator: TierStartIcicleFallAnimator

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
        elif tier_ends.size() > 1:
            configuration_warning = "Must define only one child TierEnd."
            update_configuration_warning()
        elif tier_ends.size() < 1:
            configuration_warning = "Must define a child TierEnd."
            update_configuration_warning()
    
    tier_start = Utils.get_child_by_type( \
            self, \
            TierStart)
    tier_end = Utils.get_child_by_type( \
            self, \
            TierEnd)

func setup( \
        position_or_previous_tier, \
        tier_index := -1, \
        tier_count := -1) -> void:
    assert(openness_type != OpennessType.UNKNOWN)
    assert(is_base_tier or \
            _get_size().y / \
                    Constants.CELL_SIZE.y >= \
                    Constants.LEVEL_MIN_HEIGHT_CELL_COUNT)
    
    if position_or_previous_tier is Vector2:
        self.position = position_or_previous_tier
    else:
        self.position = \
                position_or_previous_tier.tier_end_position - \
                tier_start.position
    
    if tier_index >= 0 and tier_count >= 0:
        tier_ratio_sign = Utils.add_scene( \
                self, \
                TIER_RATIO_SIGN_RESOURCE_PATH, \
                true, \
                true)
        tier_ratio_sign.position = tier_start.position
        tier_ratio_sign.text = "%s / %s" % [tier_index + 1, tier_count]
    
    if !is_base_tier:
        icicle_fall_animator = Utils.add_scene( \
                self, \
                TIER_START_ICICLE_FALL_ANIMATOR_RESOURCE_PATH, \
                true, \
                true)
        icicle_fall_animator.position = tier_start.position
        add_child(icicle_fall_animator)

func on_entered_tier(is_new_life: bool) -> void:
    if !is_new_life:
        assert(tier_ratio_sign != null)
    if tier_ratio_sign != null:
        Audio.play_sound(Sound.IGNITE)
        tier_ratio_sign.ignite()

func on_landed_in_tier() -> void:
    if icicle_fall_animator != null:
        var delay := 0.1
        Time.set_timeout(funcref(self, "_start_icicle_fall"), delay)
        Time.set_timeout( \
                funcref(self, "_end_icicle_fall"), \
                delay + IcicleFallAnimator.FALL_DURATION)
        
        # FIXME:
        var crack_ice_delay := 0.3
        Time.set_timeout( \
                funcref(Audio, "play_sound"), \
                crack_ice_delay, \
                [Sound.CRACK_ICE])
        Time.set_timeout( \
                funcref(Audio, "play_sound"), \
                crack_ice_delay + 0.2, \
                [Sound.ICICLE_1])
        Time.set_timeout( \
                funcref(Audio, "play_sound"), \
                crack_ice_delay + 0.27, \
                [Sound.ICICLE_2])
        Time.set_timeout( \
                funcref(Audio, "play_sound"), \
                crack_ice_delay + 0.38, \
                [Sound.ICICLE_5])
        Time.set_timeout( \
                funcref(Audio, "play_sound"), \
                crack_ice_delay + 0.5, \
                [Sound.ICICLE_1])
#        Time.set_timeout( \
#                funcref(Audio, "play_sound"), \
#                crack_ice_delay + 0.81, \
#                [Sound.ICICLE_2])
#        Time.set_timeout( \
#                funcref(Audio, "play_sound"), \
#                crack_ice_delay + 0.74, \
#                [Sound.ICICLE_5])

func _start_icicle_fall() -> void:
    icicle_fall_animator.fall()

func _end_icicle_fall() -> void:
    icicle_fall_animator.queue_free()
    icicle_fall_animator = null

func _get_tier_start_position() -> Vector2:
    return position + tier_start.position

func _get_tier_end_position() -> Vector2:
    return position + tier_end.position

func _get_spawn_position() -> Vector2:
    return position + tier_start.position + tier_start.spawn_position

func _get_configuration_warning() -> String:
    return configuration_warning

func _get_size() -> Vector2:
    return _get_bounding_box().size

func _set_windiness(value: Vector2) -> void:
    if tier_ratio_sign != null:
        tier_ratio_sign.windiness = value

func _get_top_position() -> Vector2:
    var bounding_box := _get_bounding_box()
    return Vector2(0.0, bounding_box.position.y)

func _get_bounding_box() -> Rect2:
    var tile_maps := Utils.get_children_by_type( \
            self, \
            TileMap)
    var bounding_box: Rect2 = \
            Geometry.get_tile_map_bounds_in_world_coordinates(tile_maps[0])
    for tile_map in tile_maps:
        bounding_box = bounding_box.merge( \
                Geometry.get_tile_map_bounds_in_world_coordinates(tile_map))
    bounding_box.position += self.position
    return bounding_box
