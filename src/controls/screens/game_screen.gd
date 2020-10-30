extends Screen
class_name GameScreen

const TYPE := ScreenType.GAME
const STARTING_LEVEL_RESOURCE_PATH := "res://src/level/level.tscn"

var level: Level

func _init().(TYPE) -> void:
    pass

func _enter_tree() -> void:
    Global.connect( \
            "display_resized", \
            self, \
            "_update_viewport_region")
    _update_viewport_region()

func _update_viewport_region() -> void:
    var game_area_region: Rect2 = Global.get_game_area_region()
    var viewport_size := get_viewport().size
    $PanelContainer.rect_size = viewport_size
    $PanelContainer/ViewportContainer.rect_position = \
            (viewport_size - game_area_region.size) * 0.5
    $PanelContainer/ViewportContainer/Viewport.size = \
            game_area_region.size

func start_level(level_id: String) -> void:
    if level != null:
        destroy_level()
    level = Utils.add_scene( \
            $PanelContainer/ViewportContainer/Viewport, \
            STARTING_LEVEL_RESOURCE_PATH, \
            true, \
            false)
    level.start(level_id)

func destroy_level() -> void:
    $PanelContainer/ViewportContainer/Viewport.remove_child(level)
    level.queue_free()
    level = null
