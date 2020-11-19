extends Screen
class_name PauseScreen

const KEY_VALUE_ROW_SCENE_PATH := "res://src/controls/key_value_row.tscn"

const TYPE := ScreenType.PAUSE

func _init().(TYPE) -> void:
    pass

func _on_activated() -> void:
    _update_stats()

func _update_stats() -> void:
    var level := _get_level()
    
    var stats_container := \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            VBoxContainer/Stats
    for row in stats_container.get_children():
        stats_container.remove_child(row)
        row.queue_free()
    
    _add_row( \
            "Level", \
            level.level_id)
    var tier_ratio_label := "%s / %s" % [
        level.current_tier_index + 1, \
        LevelConfig.LEVELS[level.level_id].tiers.size(),
    ]
    _add_row( \
            "Tier", \
            tier_ratio_label)
    _add_row( \
            "Current score", \
            str(int(level.score)))
    _add_row( \
            "High score", \
            str(SaveState.get_high_score_for_level(level.level_id)))
    _add_row( \
            "Multiplier", \
            str(level.cooldown_indicator.multiplier))
    _add_row( \
            "Speed", \
            str(level.speed_index + 1))
    _add_row( \
            "Difficulty", \
            DifficultyMode.get_type_string(Global.difficulty_mode))
    _add_row( \
            "Lives", \
            str(level.lives_count))
    _add_row( \
            "Time", \
            _get_time_string_from_seconds( \
                    Time.elapsed_play_time_actual_sec - level.start_time))

func _get_time_string_from_seconds(time_sec: float) -> String:
    var time_str := ""
    
    # Hours.
    if time_sec >= 3600:
        var hours := int(time_sec / 3600.0)
        time_sec = fmod(time_sec, 3600.0)
        time_str = "%s%d:" % [
            time_str,
            hours,
        ]
    
    # Minutes.
    if time_sec >= 60:
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

func _on_SettingsButton_pressed():
    Global.give_button_press_feedback()
    Nav.set_screen_is_open( \
            ScreenType.SETTINGS, \
            true)

func _on_ExitLevelButton_pressed():
    Global.give_button_press_feedback()
    Nav.set_screen_is_open( \
            ScreenType.MAIN_MENU, \
            true)

func _on_ResumeButton_pressed():
    Global.give_button_press_feedback()
    Nav.close_current_screen()

func _on_RestartButton_pressed():
    Global.give_button_press_feedback()
    Nav.screens[ScreenType.GAME].restart_level()
    Nav.close_current_screen()

func _get_level() -> Level:
    return Nav.screens[ScreenType.GAME].level

func _add_row( \
        key: String, \
        value: String) -> KeyValueRow:
    var row: KeyValueRow = Utils.add_scene( \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ \
                    VBoxContainer/Stats, \
            KEY_VALUE_ROW_SCENE_PATH, \
            true, \
            true)
    row.key = key
    row.value = value
    return row
