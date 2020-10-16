extends Node2D
class_name GameScreen

const STARTING_LEVEL_RESOURCE_PATH := "res://src/level/level.tscn"

var level: Level

func _enter_tree() -> void:
    Global.connect( \
            "display_resized", \
            self, \
            "_update_viewport_region")
    _update_viewport_region()

func _update_viewport_region() -> void:
    var game_area_region: Rect2 = Global.get_game_area_region()
    var viewport_size := get_viewport().size
    $ViewportContainer.rect_size = game_area_region.size
    $ViewportContainer.rect_position = \
            (viewport_size - game_area_region.size) * 0.5

func load_level(level_index: int) -> void:
    level = Utils.add_scene( \
            $ViewportContainer/Viewport, \
            STARTING_LEVEL_RESOURCE_PATH, \
            true, \
            false)

func start_level(tier_index: int) -> void:
    level.start(tier_index)
    visible = true

func stop_level() -> void:
    level.stop()
    visible = false

func destroy_level() -> void:
    $ViewportContainer/Viewport.remove_child(level)
    level.queue_free()
    level = null
