tool
extends Screen
class_name PauseScreen

const TYPE := ScreenType.PAUSE

# Array<Dictionary>
var list_items := [
    {
        label = "Level",
        type = LabeledControlItemType.TEXT,
    },
    {
        label = "Tier",
        type = LabeledControlItemType.TEXT,
    },
    {
        label = "Current score",
        type = LabeledControlItemType.TEXT,
    },
    {
        label = "High score",
        type = LabeledControlItemType.TEXT,
    },
    {
        label = "Multiplier",
        type = LabeledControlItemType.TEXT,
    },
    {
        label = "Speed",
        type = LabeledControlItemType.TEXT,
    },
    {
        label = "Difficulty",
        type = LabeledControlItemType.TEXT,
    },
    {
        label = "Lives",
        type = LabeledControlItemType.TEXT,
    },
    {
        label = "Time",
        type = LabeledControlItemType.TEXT,
    },
]

var _control_list: LabeledControlList

func _init().(TYPE) -> void:
    pass

func _ready() -> void:
    _control_list = $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/LabeledControlList
    _control_list.items = list_items

func _on_activated() -> void:
    _update_stats()

func _update_stats() -> void:
    var level: Level = Global.level
    
    _control_list.find_item("Level").text = level.level_id
    _control_list.find_item("Tier").text = \
        "%s / %s" % [
            level.current_tier_index + 1, \
            LevelConfig.get_level_config(level.level_id).tiers.size(),
        ]
    _control_list.find_item("Current score").text = str(int(level.score))
    _control_list.find_item("High score").text = \
        str(SaveState.get_high_score_for_level(level.level_id))
    _control_list.find_item("Multiplier").text = \
        "x%s" % level.cooldown_indicator.multiplier
    _control_list.find_item("Speed").text = \
        str(level.get_node("CameraHandler").speed_index + 1)
    _control_list.find_item("Difficulty").text = \
        DifficultyMode.get_type_string(Global.difficulty_mode)
    _control_list.find_item("Lives").text = \
        "%s / %s" % [
                level.lives_count,
                level.lives_count + level.falls_count,
        ]
    _control_list.find_item("Time").text = \
        _get_time_string_from_seconds( \
                Time.elapsed_play_time_actual_sec - \
                level.level_start_time)
    
    _control_list.items = list_items

func _get_time_string_from_seconds(time_sec: float) -> String:
    var time_str := ""
    
    # Hours.
    var hours := int(time_sec / 3600.0)
    time_sec = fmod(time_sec, 3600.0)
    time_str = "%s%02d:" % [
        time_str,
        hours,
    ]
    
    # Minutes.
    var minutes := int(time_sec / 60.0)
    time_sec = fmod(time_sec, 60.0)
    time_str = "%s%02d:" % [
        time_str,
        minutes,
    ]
    
    # Seconds.
    time_str = "%s%02d" % [
        time_str,
        time_sec,
    ]
    
    return time_str

func _on_ExitLevelButton_pressed():
    Global.give_button_press_feedback()
    Nav.open(ScreenType.MAIN_MENU)

func _on_ResumeButton_pressed():
    Global.give_button_press_feedback()
    Nav.close_current_screen()

func _on_RestartButton_pressed():
    Global.give_button_press_feedback()
    Nav.screens[ScreenType.GAME].restart_level()
    Nav.close_current_screen()
