extends Node

signal display_resized

var agreed_to_terms: bool
var selected_difficulty: bool
# DifficultyMode
var difficulty_mode: int
var is_giving_haptic_feedback: bool
var is_debug_panel_shown: bool setget \
        _set_is_debug_panel_shown, _get_is_debug_panel_shown
var are_mobile_controls_shown: bool
var is_multiplier_cooldown_indicator_shown: bool
var is_height_indicator_shown: bool
var is_score_display_shown: bool
var is_next_rank_at_display_shown: bool
var is_height_display_shown: bool
var is_lives_display_shown: bool
var is_tier_ratio_display_shown: bool
var is_multiplier_display_shown: bool
var is_speed_display_shown: bool
var mobile_control_version: String
var are_keyboard_controls_shown := false

var canvas_layers: CanvasLayers
var camera_controller: CameraController
var level: Level
var debug_panel: DebugPanel
var gesture_record: GestureRecord

var falls_count_since_reaching_level_end := 0

var throttled_size_changed: FuncRef = Time.throttle( \
        funcref(self, "_on_throttled_size_changed"), \
        Constants.DISPLAY_RESIZE_THROTTLE_INTERVAL_SEC)

func _init() -> void:
    _load_state()

func _load_state() -> void:
    agreed_to_terms = SaveState.get_setting( \
            SaveState.AGREED_TO_TERMS_KEY, \
            false)
    selected_difficulty = SaveState.get_setting( \
            SaveState.SELECTED_DIFFICULTY_KEY, \
            false)
    
    difficulty_mode = SaveState.get_setting( \
            SaveState.DIFFICULTY_KEY, \
            DifficultyMode.MODERATE)
    mobile_control_version = SaveState.get_setting( \
            SaveState.MOBILE_CONTROL_VERSION_KEY, \
            "1R")
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
    is_next_rank_at_display_shown = SaveState.get_setting( \
            SaveState.IS_NEXT_RANK_AT_DISPLAY_SHOWN_KEY, \
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

func set_agreed_to_terms() -> void:
    agreed_to_terms = true
    SaveState.set_setting( \
            SaveState.AGREED_TO_TERMS_KEY, \
            true)

func set_selected_difficulty() -> void:
    selected_difficulty = true
    SaveState.set_setting( \
            SaveState.SELECTED_DIFFICULTY_KEY, \
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
    
    if aspect_ratio < Constants.ASPECT_RATIO_MIN:
        # Show vertical margin around game area.
        game_area_size = Vector2( \
                viewport_size.x, \
                viewport_size.x / Constants.ASPECT_RATIO_MIN)
        game_area_position = Vector2( \
                0.0, \
                (viewport_size.y - game_area_size.y) * 0.5)
    elif aspect_ratio > Constants.ASPECT_RATIO_MAX:
        # Show horizontal margin around game area.
        game_area_size = Vector2( \
                viewport_size.y * Constants.ASPECT_RATIO_MAX, \
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
        Input.vibrate_handheld(Constants.INPUT_VIBRATE_DURATION_SEC * 1000)

func give_button_press_feedback(is_fancy := false) -> void:
    vibrate()
    if is_fancy:
        Audio.play_sound(Sound.MENU_SELECT_FANCY)
    else:
        Audio.play_sound(Sound.MENU_SELECT)

func _set_is_debug_panel_shown(is_visible: bool) -> void:
    is_debug_panel_shown = is_visible
    if debug_panel != null:
        debug_panel.visible = is_visible

func _get_is_debug_panel_shown() -> bool:
    return is_debug_panel_shown

func get_is_mobile_control_version_one_handed() -> bool:
    return mobile_control_version == "4"

func print(message: String) -> void:
    debug_panel.add_message(message)
