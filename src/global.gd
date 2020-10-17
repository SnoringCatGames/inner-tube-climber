extends Node

signal go_to_main_menu
signal go_to_game_screen
signal level_loaded
signal game_over(score)
signal display_resized

const GROUP_NAME_TIER_TILE_MAPS := "tier_tilemaps"
const GROUP_NAME_TIER_GAP_TILE_MAPS := "tier_gap_tilemaps"

const MOBILE_CONTROL_VERSION := 1

const ASPECT_RATIO_MAX := 1.0 / 1.0
const ASPECT_RATIO_MIN := 1.0 / 2.5
const LEVEL_BASE_PLATFORM_WIDTH_CELL_COUNT := 12.0
const LEVEL_VISIBLE_WIDTH_CELL_COUNT := 15.0
const LEVEL_MIN_HEIGHT_CELL_COUNT := \
        LEVEL_VISIBLE_WIDTH_CELL_COUNT / ASPECT_RATIO_MIN

const DISPLAY_RESIZE_THROTTLE_INTERVAL_SEC := 0.1

var canvas_layers: CanvasLayers
var current_level: Level
var camera_controller: CameraController

var is_debug_panel_shown := true
var debug_panel: DebugPanel

var throttled_size_changed: FuncRef = Time.throttle( \
        funcref(self, "_on_throttled_size_changed"), \
        DISPLAY_RESIZE_THROTTLE_INTERVAL_SEC)

func _enter_tree() -> void:
    get_viewport().connect( \
            "size_changed", \
            self, \
            "_on_size_changed")

func _on_size_changed() -> void:
    throttled_size_changed.call_func()

func _on_throttled_size_changed() -> void:
    emit_signal("display_resized")

func get_is_paused() -> bool:
    return get_tree().paused

func pause() -> void:
    get_tree().paused = true

func unpause() -> void:
    get_tree().paused = false

func add_overlay_to_current_scene(node: Node) -> void:
    get_tree().get_current_scene().add_child(node)

func get_game_area_region() -> Rect2:
    var viewport_size := get_viewport().size
    var aspect_ratio := viewport_size.x / viewport_size.y
    var game_area_position := Vector2.INF
    var game_area_size := Vector2.INF
    
    if aspect_ratio < Global.ASPECT_RATIO_MIN:
        # Show vertical margin around game area.
        game_area_size = Vector2( \
                viewport_size.x, \
                viewport_size.x / Global.ASPECT_RATIO_MIN)
        game_area_position = Vector2( \
                0.0, \
                (viewport_size.y - game_area_size.y) * 0.5)
    elif aspect_ratio > Global.ASPECT_RATIO_MAX:
        # Show horizontal margin around game area.
        game_area_size = Vector2( \
                viewport_size.y * Global.ASPECT_RATIO_MAX, \
                viewport_size.y)
        game_area_position = Vector2( \
                (viewport_size.x - game_area_size.x) * 0.5, \
                0.0)
    else:
        # Show no margins around game area.
        game_area_size = viewport_size
        game_area_position = Vector2.ZERO
    
    return Rect2(game_area_position, game_area_size)
