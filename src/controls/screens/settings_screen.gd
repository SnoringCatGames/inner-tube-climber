tool
extends Screen
class_name SettingsScreen

const TYPE := ScreenType.SETTINGS

# Array<Dictionary>
var list_items := [
    {
        label = "Difficulty",
        type = LabeledControlItemType.DROPDOWN,
        options = [
            DifficultyMode.get_type_string(DifficultyMode.EASY),
            DifficultyMode.get_type_string(DifficultyMode.MODERATE),
            DifficultyMode.get_type_string(DifficultyMode.HARD),
        ],
    },
    {
        label = "Control version",
        type = LabeledControlItemType.DROPDOWN,
        options = [
            "1",
            "2",
        ],
    },
    {
        label = "Music",
        type = LabeledControlItemType.CHECKBOX,
    },
    {
        label = "Sound effects",
        type = LabeledControlItemType.CHECKBOX,
    },
    {
        label = "Haptic feedback",
        type = LabeledControlItemType.CHECKBOX,
    },
    {
        label = "Multiplier cooldown indicator",
        type = LabeledControlItemType.CHECKBOX,
    },
    {
        label = "Height indicator",
        type = LabeledControlItemType.CHECKBOX,
    },
    {
        label = "Control display",
        type = LabeledControlItemType.CHECKBOX,
    },
    {
        label = "Score display",
        type = LabeledControlItemType.CHECKBOX,
    },
    {
        label = "Lives display",
        type = LabeledControlItemType.CHECKBOX,
    },
    {
        label = "Height display",
        type = LabeledControlItemType.CHECKBOX,
    },
    {
        label = "Tier ratio display",
        type = LabeledControlItemType.CHECKBOX,
    },
    {
        label = "Multiplier display",
        type = LabeledControlItemType.CHECKBOX,
    },
    {
        label = "Speed display",
        type = LabeledControlItemType.CHECKBOX,
    },
    {
        label = "Debug panel",
        type = LabeledControlItemType.CHECKBOX,
    },
]

var _control_list: LabeledControlList

func _init().(TYPE) -> void:
    pass

func _ready() -> void:
    _control_list = $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/LabeledControlList
    _control_list.connect( \
            "control_changed", \
            self, \
            "_on_control_changed")
    _control_list.items = list_items

func _on_activated() -> void:
    _initialize_selections()
    _initialize_enablement()
    _control_list.items = list_items

func _initialize_selections() -> void:
    var difficulty_item: Dictionary = \
            _control_list.find_item("Difficulty")
    for i in range(difficulty_item.options.size()):
        if difficulty_item.options[i] == \
                DifficultyMode.get_type_string(Global.difficulty_mode):
            difficulty_item.selected_index = 1
            break
    
    var control_version_item: Dictionary = \
            _control_list.find_item("Control version")
    for i in range(control_version_item.options.size()):
        if control_version_item.options[i] == \
                str(Global.mobile_control_version):
            control_version_item.selected_index = 1
            break
    
    _control_list.find_item("Haptic feedback").pressed = \
            Global.is_giving_haptic_feedback
    _control_list.find_item("Debug panel").pressed = \
            Global.is_debug_panel_shown
    _control_list.find_item("Control display").pressed = \
            Global.are_mobile_controls_shown
    
    _control_list.find_item("Multiplier cooldown indicator").pressed = \
            Global.is_multiplier_cooldown_indicator_shown
    _control_list.find_item("Height indicator").pressed = \
            Global.is_height_indicator_shown
    _control_list.find_item("Score display").pressed = \
            Global.is_score_display_shown
    _control_list.find_item("Height display").pressed = \
            Global.is_height_display_shown
    _control_list.find_item("Lives display").pressed = \
            Global.is_lives_display_shown
    _control_list.find_item("Tier ratio display").pressed = \
            Global.is_tier_ratio_display_shown
    _control_list.find_item("Multiplier display").pressed = \
            Global.is_multiplier_display_shown
    _control_list.find_item("Speed display").pressed = \
            Global.is_speed_display_shown
    
    _control_list.find_item("Music").pressed = \
            Audio.is_music_enabled
    _control_list.find_item("Sound effects").pressed = \
            Audio.is_sound_effects_enabled

func _initialize_enablement() -> void:
    var is_level_active := Global.level != null
    _control_list.find_item("Difficulty").disabled = is_level_active
    _control_list.find_item("Control version").disabled = is_level_active
    
    _control_list.find_item("Haptic feedback").disabled = \
            !Utils.get_is_mobile_device()
    
    _control_list.find_item("Debug panel").disabled = false 
    _control_list.find_item("Control display").disabled = false 
    _control_list.find_item("Multiplier cooldown indicator").disabled = false 
    _control_list.find_item("Height indicator").disabled = false 
    _control_list.find_item("Score display").disabled = false 
    _control_list.find_item("Height display").disabled = false 
    _control_list.find_item("Lives display").disabled = false 
    _control_list.find_item("Tier ratio display").disabled = false 
    _control_list.find_item("Multiplier display").disabled = false 
    _control_list.find_item("Speed display").disabled = false 
    _control_list.find_item("Music").disabled = false 
    _control_list.find_item("Sound effects").disabled = false 

func _on_control_changed(index: int) -> void:
    var item: Dictionary = list_items[index]
    
    match item.label:
        "Difficulty":
            _on_difficulty_selected( \
                    item.selected_index, \
                    item.options[item.selected_index])
        "Control version":
            _on_mobile_control_version_selected( \
                    item.selected_index, \
                    item.options[item.selected_index])
        "Haptic feedback":
            _on_haptic_feedback_pressed(item.pressed)
        "Debug panel":
            _on_debug_panel_pressed(item.pressed)
        "Control display":
            _on_mobile_control_display_pressed(item.pressed)
        "Multiplier cooldown indicator":
            _on_multiplier_cooldown_indicator_pressed(item.pressed)
        "Height indicator":
            _on_height_indicator_pressed(item.pressed)
        "Score display":
            _on_score_display_pressed(item.pressed)
        "Height display":
            _on_height_display_pressed(item.pressed)
        "Lives display":
            _on_lives_display_pressed(item.pressed)
        "Tier ratio display":
            _on_tier_ratio_display_pressed(item.pressed)
        "Multiplier display":
            _on_multiplier_display_pressed(item.pressed)
        "Speed display":
            _on_speed_display_pressed(item.pressed)
        "Music":
            _on_music_pressed(item.pressed)
        "Sound effects":
            _on_sound_effects_pressed(item.pressed)
        _:
            Utils.error()

func _update_level_displays() -> void:
    if Global.level != null:
        Global.level.update_displays()

func _on_difficulty_selected( \
        option_index: int, \
        option_label: String) -> void:
    Global.difficulty_mode = DifficultyMode.get_string_type(option_label)
    SaveState.set_setting(SaveState.DIFFICULTY_KEY, Global.difficulty_mode)
    
func _on_mobile_control_version_selected( \
        option_index: int, \
        option_label: String) -> void:
    Global.mobile_control_version = int(option_label)
    SaveState.set_setting( \
            SaveState.MOBILE_CONTROL_VERSION_KEY, \
            Global.mobile_control_version)
    
func _on_haptic_feedback_pressed(pressed: bool) -> void:
    Global.is_giving_haptic_feedback = pressed
    SaveState.set_setting( \
            SaveState.IS_GIVING_HAPTIC_FEEDBACK_KEY, \
            Global.is_giving_haptic_feedback)
    
func _on_debug_panel_pressed(pressed: bool) -> void:
    Global.is_debug_panel_shown = pressed
    SaveState.set_setting( \
            SaveState.IS_DEBUG_PANEL_SHOWN_KEY, \
            Global.is_debug_panel_shown)
    _update_level_displays()
    
func _on_mobile_control_display_pressed(pressed: bool) -> void:
    Global.are_mobile_controls_shown = pressed
    SaveState.set_setting( \
            SaveState.ARE_MOBILE_CONTROLS_SHOWN_KEY, \
            Global.are_mobile_controls_shown)
    _update_level_displays()
    
func _on_multiplier_cooldown_indicator_pressed(pressed: bool) -> void:
    Global.is_multiplier_cooldown_indicator_shown = pressed
    SaveState.set_setting( \
            SaveState.IS_MULTIPLIER_COOLDOWN_INDICATOR_SHOWN_KEY, \
            Global.is_multiplier_cooldown_indicator_shown)
    _update_level_displays()
    
func _on_height_indicator_pressed(pressed: bool) -> void:
    Global.is_height_indicator_shown = pressed
    SaveState.set_setting( \
            SaveState.IS_HEIGHT_INDICATOR_SHOWN_KEY, \
            Global.is_height_indicator_shown)
    _update_level_displays()
    
func _on_score_display_pressed(pressed: bool) -> void:
    Global.is_score_display_shown = pressed
    SaveState.set_setting( \
            SaveState.IS_SCORE_DISPLAY_SHOWN_KEY, \
            Global.is_score_display_shown)
    _update_level_displays()
    
func _on_height_display_pressed(pressed: bool) -> void:
    Global.is_height_display_shown = pressed
    SaveState.set_setting( \
            SaveState.IS_HEIGHT_DISPLAY_SHOWN_KEY, \
            Global.is_height_display_shown)
    _update_level_displays()
    
func _on_lives_display_pressed(pressed: bool) -> void:
    Global.is_lives_display_shown = pressed
    SaveState.set_setting( \
            SaveState.IS_LIVES_DISPLAY_SHOWN_KEY, \
            Global.is_lives_display_shown)
    _update_level_displays()
    
func _on_tier_ratio_display_pressed(pressed: bool) -> void:
    Global.is_tier_ratio_display_shown = pressed
    SaveState.set_setting( \
            SaveState.IS_TIER_RATIO_DISPLAY_SHOWN_KEY, \
            Global.is_tier_ratio_display_shown)
    _update_level_displays()
    
func _on_multiplier_display_pressed(pressed: bool) -> void:
    Global.is_multiplier_display_shown = pressed
    SaveState.set_setting( \
            SaveState.IS_MULTIPLIER_DISPLAY_SHOWN_KEY, \
            Global.is_multiplier_display_shown)
    _update_level_displays()
    
func _on_speed_display_pressed(pressed: bool) -> void:
    Global.is_speed_display_shown = pressed
    SaveState.set_setting( \
            SaveState.IS_SPEED_DISPLAY_SHOWN_KEY, \
            Global.is_speed_display_shown)
    _update_level_displays()
    
func _on_music_pressed(pressed: bool):
    Audio.set_music_enabled(pressed)
    SaveState.set_setting( \
            SaveState.IS_MUSIC_ENABLED_KEY, \
            Audio.is_music_enabled)
    
func _on_sound_effects_pressed(pressed: bool):
    Audio.set_sound_effects_enabled(pressed)
    SaveState.set_setting( \
            SaveState.IS_SOUND_EFFECTS_ENABLED_KEY, \
            Audio.is_sound_effects_enabled)
