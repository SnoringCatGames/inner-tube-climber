extends Node

signal display_resized

const GROUP_NAME_TIER_TILE_MAPS := "tier_tilemaps"
const GROUP_NAME_TIER_GAP_TILE_MAPS := "tier_gap_tilemaps"

const PLAYER_SIZE_MULTIPLIER := 1.5

const ASPECT_RATIO_MAX := 1.0 / 1.0
const ASPECT_RATIO_MIN := 1.0 / 2.5
const LEVEL_BASE_PLATFORM_WIDTH_CELL_COUNT := 12.0
const LEVEL_VISIBLE_WIDTH_CELL_COUNT := 15.0
const LEVEL_MIN_HEIGHT_CELL_COUNT := \
        LEVEL_VISIBLE_WIDTH_CELL_COUNT / ASPECT_RATIO_MIN

const INPUT_VIBRATE_DURATION_SEC := 0.01

const DISPLAY_RESIZE_THROTTLE_INTERVAL_SEC := 0.1

# DifficultyMode
var difficulty_mode: int
var is_giving_haptic_feedback: bool
var is_debug_panel_shown: bool setget \
        _set_is_debug_panel_shown, _get_is_debug_panel_shown
var are_mobile_controls_shown: bool
var is_multiplier_cooldown_indicator_shown: bool
var is_height_indicator_shown: bool
var is_score_display_shown: bool
var is_height_display_shown: bool
var is_lives_display_shown: bool
var is_tier_ratio_display_shown: bool
var is_multiplier_display_shown: bool
var is_speed_display_shown: bool
var mobile_control_version: int
var are_keyboard_controls_shown := false

var canvas_layers: CanvasLayers
var camera_controller: CameraController

var debug_panel: DebugPanel

var falls_count_since_reaching_level_end := 0

var throttled_size_changed: FuncRef = Time.throttle( \
        funcref(self, "_on_throttled_size_changed"), \
        DISPLAY_RESIZE_THROTTLE_INTERVAL_SEC)

func _init() -> void:
    _load_state()

func _load_state() -> void:
    difficulty_mode = SaveState.get_setting( \
            SaveState.DIFFICULTY_KEY, \
            DifficultyMode.MODERATE)
    mobile_control_version = SaveState.get_setting( \
            SaveState.MOBILE_CONTROL_VERSION_KEY, \
            1)
    is_giving_haptic_feedback = SaveState.get_setting( \
            SaveState.IS_GIVING_HAPTIC_FEEDBACK_KEY, \
            Utils.get_is_android_device())
    
    is_debug_panel_shown = SaveState.get_setting( \
            SaveState.IS_DEBUG_PANEL_SHOWN_KEY, \
            false)
    are_mobile_controls_shown = SaveState.get_setting( \
            SaveState.ARE_MOBILE_CONTROLS_SHOWN_KEY, \
            true)
    is_multiplier_cooldown_indicator_shown = SaveState.get_setting( \
            SaveState.IS_MULTIPLIER_COOLDOWN_INDICATOR_SHOWN_KEY, \
            true)
    is_height_indicator_shown = SaveState.get_setting( \
            SaveState.IS_HEIGHT_INDICATOR_SHOWN_KEY, \
            true)
    is_score_display_shown = SaveState.get_setting( \
            SaveState.IS_SCORE_DISPLAY_SHOWN_KEY, \
            true)
    is_height_display_shown = SaveState.get_setting( \
            SaveState.IS_HEIGHT_DISPLAY_SHOWN_KEY, \
            false)
    is_lives_display_shown = SaveState.get_setting( \
            SaveState.IS_LIVES_DISPLAY_SHOWN_KEY, \
            true)
    is_tier_ratio_display_shown = SaveState.get_setting( \
            SaveState.IS_TIER_RATIO_DISPLAY_SHOWN_KEY, \
            false)
    is_multiplier_display_shown = SaveState.get_setting( \
            SaveState.IS_MULTIPLIER_DISPLAY_SHOWN_KEY, \
            false)
    is_speed_display_shown = SaveState.get_setting( \
            SaveState.IS_SPEED_DISPLAY_SHOWN_KEY, \
            false)
    
    Audio.is_music_enabled = SaveState.get_setting( \
            SaveState.IS_MUSIC_ENABLED_KEY, \
            true)
    Audio.is_sound_effects_enabled = SaveState.get_setting( \
            SaveState.IS_SOUND_EFFECTS_ENABLED_KEY, \
            true)

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

func vibrate() -> void:
    if is_giving_haptic_feedback:
        Input.vibrate_handheld(INPUT_VIBRATE_DURATION_SEC * 1000)

func give_button_press_feedback() -> void:
    vibrate()
    Audio.button_press_sfx_player.play()

func _set_is_debug_panel_shown(is_visible: bool) -> void:
    is_debug_panel_shown = is_visible
    if debug_panel != null:
        debug_panel.visible = is_visible

func _get_is_debug_panel_shown() -> bool:
    return is_debug_panel_shown
