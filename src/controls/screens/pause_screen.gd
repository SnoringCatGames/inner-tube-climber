tool
extends Screen
class_name PauseScreen

const TYPE := ScreenType.PAUSE
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true

# Array<Dictionary>
var list_items := [
    {
        label = "Level:",
        type = LabeledControlItemType.TEXT,
    },
    {
        label = "Tier:",
        type = LabeledControlItemType.TEXT,
    },
    {
        label = "Current score:",
        type = LabeledControlItemType.TEXT,
    },
    {
        label = "High score:",
        type = LabeledControlItemType.TEXT,
    },
    {
        label = "Multiplier:",
        type = LabeledControlItemType.TEXT,
    },
    {
        label = "Speed:",
        type = LabeledControlItemType.TEXT,
    },
    {
        label = "Difficulty:",
        type = LabeledControlItemType.TEXT,
    },
    {
        label = "Lives:",
        type = LabeledControlItemType.TEXT,
    },
    {
        label = "Time:",
        type = LabeledControlItemType.TEXT,
    },
]

var _control_list: LabeledControlList

func _init().( \
        TYPE, \
        INCLUDES_STANDARD_HIERARCHY, \
        INCLUDES_NAV_BAR, \
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass

func _ready() -> void:
    _control_list = $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/LabeledControlList
    _control_list.items = list_items

func _on_activated() -> void:
    ._on_activated()
    _update_stats()
    _give_button_focus($FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/VBoxContainer/ \
            ResumeButton)

func _get_focused_button() -> ShinyButton:
    return $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer/ResumeButton as \
            ShinyButton

func _update_stats() -> void:
    var level: Level = Global.level
    
    _control_list.find_item("Level:").text = level.level_id
    _control_list.find_item("Tier:").text = level.get_tier_ratio()
    _control_list.find_item("Current score:").text = str(int(level.score))
    _control_list.find_item("High score:").text = \
        str(SaveState.get_level_high_score(level.level_id))
    _control_list.find_item("Multiplier:").text = \
        "x%s" % level.cooldown_indicator.multiplier
    _control_list.find_item("Speed:").text = \
        str(level.get_node("CameraHandler:").speed_index + 1)
    _control_list.find_item("Difficulty:").text = \
        DifficultyMode.get_type_string(Global.difficulty_mode)
    _control_list.find_item("Lives:").text = \
        "%s / %s" % [
                level.lives_count,
                level.lives_count + level.falls_count,
        ]
    _control_list.find_item("Time:").text = \
        Utils.get_time_string_from_seconds( \
                Time.elapsed_play_time_actual_sec - \
                level.level_start_time)
    
    _control_list.items = list_items

func _on_ExitLevelButton_pressed():
    Global.give_button_press_feedback()
    Audio.cross_fade_music(Audio.MAIN_MENU_MUSIC_PLAYER_INDEX)
    Nav.screens[ScreenType.GAME].destroy_level()
    Nav.open(ScreenType.MAIN_MENU, true)

func _on_ResumeButton_pressed():
    Global.give_button_press_feedback()
    Nav.close_current_screen()

func _on_RestartButton_pressed():
    Global.give_button_press_feedback()
    Nav.screens[ScreenType.GAME].restart_level()
    Nav.close_current_screen(true)
