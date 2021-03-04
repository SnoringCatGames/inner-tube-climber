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
    
    if Constants.DEBUG or Constants.PLAYTEST:
        $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
                CenterContainer/VBoxContainer/MoreLivesWrapper.visible = true

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

func _on_ExitLevelButton_pressed() -> void:
    Global.give_button_press_feedback()
    Nav.close_current_screen()
    Analytics.event( \
            "level", \
            "quit", \
            LevelConfig.get_level_tier_version_string( \
                    Global.level.level_id, \
                    Global.level.current_tier_id), \
            Time.elapsed_play_time_actual_sec - Global.level.tier_start_time)
    Global.level.quit()

func _on_ResumeButton_pressed() -> void:
    Global.give_button_press_feedback()
    Nav.close_current_screen()

func _on_RestartButton_pressed() -> void:
    Global.give_button_press_feedback()
    Nav.screens[ScreenType.GAME].restart_level()
    Nav.close_current_screen(true)

func _on_MoreLivesButton_pressed() -> void:
    if Constants.DEBUG or Constants.PLAYTEST:
        Global.give_button_press_feedback()
        Time.set_timeout(funcref(Audio, "play_sound"), 0.2, [Sound.ACHIEVEMENT])
        for i in range(10):
            Global.level.add_life()

func _on_SendRecentGestureEventsForDebugging_pressed() -> void:
    var recent_events_str := ""
    var events: Array = Global.level.mobile_control_ui.mobile_control_input \
            .recent_gesture_events_for_debugging
    for event in events:
        recent_events_str += event.to_string()
    OS.set_clipboard(recent_events_str)
    
    var body_str: String
    if Utils.get_is_ios_device():
        # iOS doesn't allow us to add things to the clipboard.
        for index in range(events.size() - 50):
            recent_events_str += events[index].to_string()
        body_str = recent_events_str
    else:
        body_str = "Events have been copied to your clipboard. " + \
                "Please paste them here!"
    
    body_str = body_str.http_escape()
    var subject_str := \
            "Events: slightly used, minor repairs needed.".http_escape()
    var query_string := \
            "?subject=" + subject_str + "&body=" + body_str
    var link := "mailto:support@snoringcat.games" + query_string
    OS.shell_open(link)
