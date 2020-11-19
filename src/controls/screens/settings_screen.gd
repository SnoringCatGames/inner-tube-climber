tool
extends Screen
class_name SettingsScreen

const ROW_HEIGHT := 32.0

const TYPE := ScreenType.SETTINGS

var container: VBoxContainer
var difficulty_option_button: OptionButton
var haptic_feedback_checkbox: CheckBox
var debug_panel_checkbox: CheckBox
var mobile_control_version_option_button: OptionButton
var mobile_control_display_checkbox: CheckBox
var multiplier_cooldown_indicator_checkbox: CheckBox
var height_indicator_checkbox: CheckBox
var score_display_checkbox: CheckBox
var height_display_checkbox: CheckBox
var lives_display_checkbox: CheckBox
var tier_ratio_display_checkbox: CheckBox
var muliplier_display_checkbox: CheckBox
var speed_display_checkbox: CheckBox
var music_checkbox: CheckBox
var sound_effects_checkbox: CheckBox

func _init().(TYPE) -> void:
    pass

func _enter_tree() -> void:
    _initialize_references()
    _initialize_options()
    _initialize_selections()
    _initialize_sizes()

func _initialize_references() -> void:
    container = \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/VBoxContainer
    difficulty_option_button = \
            container.get_node("Difficulty/OptionButton")
    haptic_feedback_checkbox = \
            container.get_node("HapticFeedback/CheckBox")
    debug_panel_checkbox = \
            container.get_node("DebugPanel/CheckBox")
    mobile_control_version_option_button = \
            container.get_node("MobileControlVersion/OptionButton")
    mobile_control_display_checkbox = \
            container.get_node("MobileControlDisplay/CheckBox")
    multiplier_cooldown_indicator_checkbox = \
            container.get_node("MultiplierCooldownIndicator/CheckBox")
    height_indicator_checkbox = \
            container.get_node("HeightIndicator/CheckBox")
    score_display_checkbox = \
            container.get_node("ScoreDisplay/CheckBox")
    height_display_checkbox = \
            container.get_node("HeightDisplay/CheckBox")
    lives_display_checkbox = \
            container.get_node("LivesDisplay/CheckBox")
    tier_ratio_display_checkbox = \
            container.get_node("TierRatioDisplay/CheckBox")
    muliplier_display_checkbox = \
            container.get_node("MultiplierDisplay/CheckBox")
    speed_display_checkbox = \
            container.get_node("SpeedDisplay/CheckBox")
    music_checkbox = \
            container.get_node("Music/CheckBox")
    sound_effects_checkbox = \
            container.get_node("SoundEffects/CheckBox")

func _initialize_options() -> void:
    difficulty_option_button.clear()
    difficulty_option_button.add_item( \
            DifficultyMode.get_type_string(DifficultyMode.EASY))
    difficulty_option_button.add_item( \
            DifficultyMode.get_type_string(DifficultyMode.MODERATE))
    difficulty_option_button.add_item( \
            DifficultyMode.get_type_string(DifficultyMode.HARD))
    
    mobile_control_version_option_button.clear()
    mobile_control_version_option_button.add_item("1")
    mobile_control_version_option_button.add_item("2")

func _initialize_selections() -> void:
    for i in range(difficulty_option_button.get_item_count()):
        if difficulty_option_button.get_item_text(i) == \
                DifficultyMode.get_type_string(Global.difficulty_mode):
            difficulty_option_button.select(i)
            break
    
    for i in range(mobile_control_version_option_button.get_item_count()):
        if mobile_control_version_option_button.get_item_text(i) == \
                str(Global.mobile_control_version):
            mobile_control_version_option_button.select(i)
            break
    
    haptic_feedback_checkbox.pressed = Global.is_giving_haptic_feedback
    debug_panel_checkbox.pressed = Global.is_debug_panel_shown
    mobile_control_display_checkbox.pressed = Global.are_mobile_controls_shown
    
    multiplier_cooldown_indicator_checkbox.pressed = \
            Global.is_multiplier_cooldown_indicator_shown
    height_indicator_checkbox.pressed = Global.is_height_indicator_shown
    score_display_checkbox.pressed = Global.is_score_display_shown
    height_display_checkbox.pressed = Global.is_height_display_shown
    lives_display_checkbox.pressed = Global.is_lives_display_shown
    tier_ratio_display_checkbox.pressed = Global.is_tier_ratio_display_shown
    muliplier_display_checkbox.pressed = Global.is_multiplier_display_shown
    speed_display_checkbox.pressed = Global.is_speed_display_shown
    
    music_checkbox.pressed = Audio.is_music_enabled
    sound_effects_checkbox.pressed = Audio.is_sound_effects_enabled

func _initialize_sizes() -> void:
    for child in container.get_children():
        var row: LabeledControlRow = child
        row.size_flags_horizontal = Control.SIZE_FILL
        row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        row.rect_min_size = Vector2(0.0, ROW_HEIGHT)

func _on_difficulty_selected(index: int) -> void:
    var difficulty_str := difficulty_option_button.get_item_text(index)
    Global.difficulty_mode = DifficultyMode.get_string_type(difficulty_str)
    SaveState.set_setting(SaveState.DIFFICULTY_KEY, Global.difficulty_mode)
    Global.give_button_press_feedback()

func _on_haptic_feedback_pressed() -> void:
    Global.is_giving_haptic_feedback = haptic_feedback_checkbox.pressed
    SaveState.set_setting( \
            SaveState.IS_GIVING_HAPTIC_FEEDBACK_KEY, \
            Global.is_giving_haptic_feedback)
    Global.give_button_press_feedback()

func _on_debug_panel_pressed() -> void:
    Global.is_debug_panel_shown = debug_panel_checkbox.pressed
    SaveState.set_setting( \
            SaveState.IS_DEBUG_PANEL_SHOWN_KEY, \
            Global.is_debug_panel_shown)
    Global.give_button_press_feedback()

func _on_mobile_control_display_pressed() -> void:
    Global.are_mobile_controls_shown = mobile_control_display_checkbox.pressed
    SaveState.set_setting( \
            SaveState.ARE_MOBILE_CONTROLS_SHOWN_KEY, \
            Global.are_mobile_controls_shown)
    Global.give_button_press_feedback()

func _on_mobile_control_version_selected(index: int) -> void:
    var version_str := \
            mobile_control_version_option_button.get_item_text(index)
    Global.mobile_control_version = int(version_str)
    SaveState.set_setting( \
            SaveState.MOBILE_CONTROL_VERSION_KEY, \
            Global.mobile_control_version)
    Global.give_button_press_feedback()

func _on_multiplier_cooldown_indicator_pressed() -> void:
    Global.is_multiplier_cooldown_indicator_shown = \
            multiplier_cooldown_indicator_checkbox.pressed
    SaveState.set_setting( \
            SaveState.IS_MULTIPLIER_COOLDOWN_INDICATOR_SHOWN_KEY, \
            Global.is_multiplier_cooldown_indicator_shown)
    _update_level_displays()
    Global.give_button_press_feedback()

func _on_height_indicator_pressed() -> void:
    Global.is_height_indicator_shown = height_indicator_checkbox.pressed
    SaveState.set_setting( \
            SaveState.IS_HEIGHT_INDICATOR_SHOWN_KEY, \
            Global.is_height_indicator_shown)
    _update_level_displays()
    Global.give_button_press_feedback()

func _on_score_display_pressed() -> void:
    Global.is_score_display_shown = score_display_checkbox.pressed
    SaveState.set_setting( \
            SaveState.IS_SCORE_DISPLAY_SHOWN_KEY, \
            Global.is_score_display_shown)
    _update_level_displays()
    Global.give_button_press_feedback()

func _on_height_display_pressed() -> void:
    Global.is_height_display_shown = height_display_checkbox.pressed
    SaveState.set_setting( \
            SaveState.IS_HEIGHT_DISPLAY_SHOWN_KEY, \
            Global.is_height_display_shown)
    _update_level_displays()
    Global.give_button_press_feedback()

func _on_lives_display_pressed() -> void:
    Global.is_lives_display_shown = lives_display_checkbox.pressed
    SaveState.set_setting( \
            SaveState.IS_LIVES_DISPLAY_SHOWN_KEY, \
            Global.is_lives_display_shown)
    _update_level_displays()
    Global.give_button_press_feedback()

func _on_tier_ratio_display_pressed() -> void:
    Global.is_tier_ratio_display_shown = tier_ratio_display_checkbox.pressed
    SaveState.set_setting( \
            SaveState.IS_TIER_RATIO_DISPLAY_SHOWN_KEY, \
            Global.is_tier_ratio_display_shown)
    _update_level_displays()
    Global.give_button_press_feedback()

func _on_multiplier_display_pressed() -> void:
    Global.is_multiplier_display_shown = muliplier_display_checkbox.pressed
    SaveState.set_setting( \
            SaveState.IS_MULTIPLIER_DISPLAY_SHOWN_KEY, \
            Global.is_multiplier_display_shown)
    _update_level_displays()
    Global.give_button_press_feedback()

func _on_speed_display_pressed() -> void:
    Global.is_speed_display_shown = speed_display_checkbox.pressed
    SaveState.set_setting( \
            SaveState.IS_SPEED_DISPLAY_SHOWN_KEY, \
            Global.is_speed_display_shown)
    _update_level_displays()
    Global.give_button_press_feedback()

func _on_music_pressed():
    Audio.set_music_enabled(music_checkbox.pressed)
    SaveState.set_setting( \
            SaveState.IS_MUSIC_ENABLED_KEY, \
            Audio.is_music_enabled)
    Global.give_button_press_feedback()

func _on_sound_effects_pressed():
    Audio.set_sound_effects_enabled(sound_effects_checkbox.pressed)
    SaveState.set_setting( \
            SaveState.IS_SOUND_EFFECTS_ENABLED_KEY, \
            Audio.is_sound_effects_enabled)
    Global.give_button_press_feedback()

func _on_mobile_control_version_pressed() -> void:
    Global.give_button_press_feedback()

func _on_difficulty_pressed() -> void:
    Global.give_button_press_feedback()

func _on_CreditsButton_pressed() -> void:
    Global.give_button_press_feedback()
    Nav.set_screen_is_open( \
            ScreenType.CREDITS, \
            true)

func _update_level_displays() -> void:
    var level: Level = Nav.screens[ScreenType.GAME].level
    if level != null:
        level.update_displays()
