extends Node

signal display_resized

const GROUP_NAME_TIER_TILE_MAPS := "tier_tilemaps"
const GROUP_NAME_TIER_GAP_TILE_MAPS := "tier_gap_tilemaps"

const SHOWS_MOBILE_CONTROLS := true
const MOBILE_CONTROL_VERSION := 1
const PLAYER_SIZE_MULTIPLIER := 1.5

const ASPECT_RATIO_MAX := 1.0 / 1.0
const ASPECT_RATIO_MIN := 1.0 / 2.5
const LEVEL_BASE_PLATFORM_WIDTH_CELL_COUNT := 12.0
const LEVEL_VISIBLE_WIDTH_CELL_COUNT := 15.0
const LEVEL_MIN_HEIGHT_CELL_COUNT := \
        LEVEL_VISIBLE_WIDTH_CELL_COUNT / ASPECT_RATIO_MIN

const INPUT_VIBRATE_DURATION_SEC := 0.01

const DISPLAY_RESIZE_THROTTLE_INTERVAL_SEC := 0.1

const IS_DEBUG_PANEL_SHOWN_BY_DEFAULT := false

var is_giving_haptic_feedback := false

var difficulty_mode := DifficultyMode.MODERATE

var canvas_layers: CanvasLayers
var camera_controller: CameraController

var debug_panel: DebugPanel

var falls_count_since_reaching_level_end := 0

var throttled_size_changed: FuncRef = Time.throttle( \
        funcref(self, "_on_throttled_size_changed"), \
        DISPLAY_RESIZE_THROTTLE_INTERVAL_SEC)

func _init() -> void:
    self.is_giving_haptic_feedback = Utils.get_is_android_device()

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

func register_main(main: Node) -> void:
    camera_controller = CameraController.new()
    main.add_child(camera_controller)
    
    canvas_layers = CanvasLayers.new()
    main.add_child(canvas_layers)
    canvas_layers.is_debug_panel_shown = IS_DEBUG_PANEL_SHOWN_BY_DEFAULT

func vibrate() -> void:
    if is_giving_haptic_feedback:
        Input.vibrate_handheld(INPUT_VIBRATE_DURATION_SEC * 1000)

func give_button_press_feedback() -> void:
    vibrate()
    Audio.button_press_sfx_player.play()
