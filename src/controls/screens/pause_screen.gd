extends Screen
class_name PauseScreen

const KEY_VALUE_ROW_SCENE_PATH := "res://src/controls/key_value_row.tscn"

const TYPE := ScreenType.PAUSE

func _init().(TYPE) -> void:
    pass

func _on_activated() -> void:
    _update_stats()

func _update_stats() -> void:
    var level: Level = Global.level
    
    var stats_container := \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/Stats
    for row in stats_container.get_children():
        stats_container.remove_child(row)
        row.queue_free()
    
    var row_data := [
        ["Level", level.level_id],
        ["Tier", \
            "%s / %s" % [
                level.current_tier_index + 1, \
                LevelConfig.get_level_config(level.level_id).tiers.size(),
            ]],
        ["Current score", str(int(level.score))],
        ["High score", \
            str(SaveState.get_high_score_for_level(level.level_id))],
        ["Multiplier", \
            "x%s" % level.cooldown_indicator.multiplier],
        ["Speed", \
            str(level.get_node("CameraHandler").speed_index + 1)],
        ["Difficulty", \
            DifficultyMode.get_type_string(Global.difficulty_mode)],
        ["Lives", \
            "%s / %s" % [
                    level.lives_count,
                    level.lives_count + level.falls_count,
            ]],
        ["Time", \
            _get_time_string_from_seconds( \
                    Time.elapsed_play_time_actual_sec - \
                    level.level_start_time)],
    ]
    var is_odd := true
    for data in row_data:
        _add_row(data[0], data[1], is_odd)
        is_odd = !is_odd

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

func _add_row( \
        key: String, \
        value: String, \
        is_odd_row: bool) -> KeyValueRow:
    var row: KeyValueRow = Utils.add_scene( \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ \
                    ScrollContainer/CenterContainer/VBoxContainer/Stats, \
            KEY_VALUE_ROW_SCENE_PATH, \
            true, \
            true)
    row.key = key
    row.value = value
    row.is_odd_row = is_odd_row
    return row
