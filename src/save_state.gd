extends Node

const CONFIG_FILE_PATH := "user://settings.cfg"
const HIGH_SCORES_SECTION_KEY := "high_scores"
const HIGH_TIER_SECTION_KEY := "high_tiers"
const TOTAL_PLAYS_SECTION_KEY := "total_plays"
const TOTAL_FALLS_SECTION_KEY := "total_falls"
const TOTAL_FALLS_ON_TIER_SECTION_KEY := "total_falls_on_tier"
const ALL_SCORES_SECTION_KEY := "all_scores"
const ALL_FINISHED_SCORES_SECTION_KEY := "all_finished_scores"
const IS_UNLOCKED_SECTION_KEY := "is_unlocked"
const HAS_FINISHED_SECTION_KEY := "has_finished"
const HAS_THREE_LOOPED_SECTION_KEY := "has_three_looped"
const SETTINGS_SECTION_KEY := "settings"
const MISCELLANEOUS_SECTION_KEY := "miscellaneous"
const VERSIONS_SECTION_KEY := "versions"

const CLIENT_ID_KEY := "cliend_id"
const AGREED_TO_TERMS_KEY := "agreed_to_terms"
const SELECTED_DIFFICULTY_KEY := "selected_difficulty"
const NEW_UNLOCKED_LEVELS_KEY := "new_unlocked_levels"
const FINISHED_LEVEL_STREAK_KEY := "finished_level_streak"
const FAILED_LEVEL_STREAK_KEY := "failed_level_streak"
const GAVE_FEEDBACK_KEY := "gave_feedback"
const DIFFICULTY_KEY := "difficulty"
const IS_GIVING_HAPTIC_FEEDBACK_KEY := "is_giving_haptic_feedback"
const IS_DEBUG_PANEL_SHOWN_KEY := "is_debug_panel_shown"
const ARE_MOBILE_CONTROLS_SHOWN_KEY := "are_mobile_controls_shown"
const MOBILE_CONTROL_VERSION_KEY := "mobile_control_version"
const IS_MULTIPLIER_COOLDOWN_INDICATOR_SHOWN_KEY := \
        "is_multiplier_cooldown_indicator_shown"
const IS_HEIGHT_INDICATOR_SHOWN_KEY := "is_height_indicator_shown"
const IS_SCORE_DISPLAY_SHOWN_KEY := "is_score_display_shown"
const IS_NEXT_RANK_AT_DISPLAY_SHOWN_KEY := "is_next_rank_at_display_shown"
const IS_HEIGHT_DISPLAY_SHOWN_KEY := "is_height_display_shown"
const IS_LIVES_DISPLAY_SHOWN_KEY := "is_lives_display_shown"
const IS_TIER_RATIO_DISPLAY_SHOWN_KEY := "is_tier_ratio_display_shown"
const IS_MULTIPLIER_DISPLAY_SHOWN_KEY := "is_multiplier_display_shown"
const IS_SPEED_DISPLAY_SHOWN_KEY := "is_speed_display_shown"
const IS_MUSIC_ENABLED_KEY := "is_music_enabled"
const IS_SOUND_EFFECTS_ENABLED_KEY := "is_sound_effects_enabled"
const SCORE_VERSION_KEY := "score_v"

var config := ConfigFile.new()

func _init() -> void:
    _load_config()

func _load_config() -> void:
    var status := config.load(CONFIG_FILE_PATH)
    if status != OK and \
            status != ERR_FILE_NOT_FOUND:
        Utils.error("An error occurred loading game state: %s" % status)

func save_config() -> void:
    var status := config.save(CONFIG_FILE_PATH)
    if status != OK:
        Utils.error("An error occurred saving game state: %s" % status)

func set_level_high_score( \
        level_id: String, \
        high_score: int) -> void:
    config.set_value( \
            HIGH_SCORES_SECTION_KEY, \
            level_id, \
            high_score)
    save_config()

func get_level_high_score(level_id: String) -> int:
    return config.get_value( \
            HIGH_SCORES_SECTION_KEY, \
            level_id, \
            0) as int

func set_level_high_tier( \
        level_id: String, \
        high_tier: int) -> void:
    config.set_value( \
            HIGH_TIER_SECTION_KEY, \
            level_id, \
            high_tier)
    save_config()

func get_level_high_tier(level_id: String) -> int:
    return config.get_value( \
            HIGH_TIER_SECTION_KEY, \
            level_id, \
            0) as int

func set_level_total_plays( \
        level_id: String, \
        total_plays: int) -> void:
    config.set_value( \
            TOTAL_PLAYS_SECTION_KEY, \
            level_id, \
            total_plays)
    save_config()

func get_level_total_plays(level_id: String) -> int:
    return config.get_value( \
            TOTAL_PLAYS_SECTION_KEY, \
            level_id, \
            0) as int

func set_level_total_falls( \
        level_id: String, \
        total_falls: int) -> void:
    config.set_value( \
            TOTAL_FALLS_SECTION_KEY, \
            level_id, \
            total_falls)
    save_config()

func get_level_total_falls(level_id: String) -> int:
    return config.get_value( \
            TOTAL_FALLS_SECTION_KEY, \
            level_id, \
            0) as int

func set_level_total_falls_on_tier( \
        level_id: String, \
        tier_id: String, \
        total_falls_on_tier: int) -> void:
    var key := level_id + ":" + tier_id
    config.set_value( \
            TOTAL_FALLS_ON_TIER_SECTION_KEY, \
            key, \
            total_falls_on_tier)
    save_config()

func get_level_total_falls_on_tier( \
        level_id: String, \
        tier_id: String) -> int:
    var key := level_id + ":" + tier_id
    return config.get_value( \
            TOTAL_FALLS_ON_TIER_SECTION_KEY, \
            key, \
            0) as int

func set_level_all_scores( \
        level_id: String, \
        level_all_scores: Array) -> void:
    config.set_value( \
            ALL_SCORES_SECTION_KEY, \
            level_id, \
            level_all_scores)
    save_config()

func get_level_all_scores(level_id: String) -> Array:
    return config.get_value( \
            ALL_SCORES_SECTION_KEY, \
            level_id, \
            []) as Array

func set_level_all_finished_scores( \
        level_id: String, \
        level_all_finished_scores: Array) -> void:
    config.set_value( \
            ALL_FINISHED_SCORES_SECTION_KEY, \
            level_id, \
            level_all_finished_scores)
    save_config()

func get_level_all_finished_scores(level_id: String) -> Array:
    return config.get_value( \
            ALL_FINISHED_SCORES_SECTION_KEY, \
            level_id, \
            []) as Array

func set_level_is_unlocked( \
        level_id: String, \
        is_unlocked: bool) -> void:
    config.set_value( \
            IS_UNLOCKED_SECTION_KEY, \
            level_id, \
            is_unlocked)
    save_config()

func get_level_is_unlocked(level_id: String) -> bool:
    return config.get_value( \
            IS_UNLOCKED_SECTION_KEY, \
            level_id, \
            false) as bool or \
            Constants.ARE_ALL_LEVELS_UNLOCKED

func set_new_unlocked_levels(new_unlocked_levels: Array) -> void:
    config.set_value( \
            MISCELLANEOUS_SECTION_KEY, \
            NEW_UNLOCKED_LEVELS_KEY, \
            new_unlocked_levels)
    save_config()

func get_new_unlocked_levels() -> Array:
    return config.get_value( \
            MISCELLANEOUS_SECTION_KEY, \
            NEW_UNLOCKED_LEVELS_KEY, \
            []) as Array

func set_level_has_finished( \
        level_id: String, \
        has_finished: bool) -> void:
    config.set_value( \
            HAS_FINISHED_SECTION_KEY, \
            level_id, \
            has_finished)
    save_config()

func get_level_has_finished(level_id: String) -> bool:
    return config.get_value( \
            HAS_FINISHED_SECTION_KEY, \
            level_id, \
            false) as bool

func set_level_has_three_looped( \
        level_id: String, \
        has_three_looped: bool) -> void:
    config.set_value( \
            HAS_THREE_LOOPED_SECTION_KEY, \
            level_id, \
            has_three_looped)
    save_config()

func get_level_has_three_looped(level_id: String) -> bool:
    return config.get_value( \
            HAS_THREE_LOOPED_SECTION_KEY, \
            level_id, \
            false) as bool

func set_finished_level_streak(streak: int) -> void:
    config.set_value( \
            MISCELLANEOUS_SECTION_KEY, \
            FINISHED_LEVEL_STREAK_KEY, \
            streak)
    save_config()

func get_finished_level_streak() -> int:
    return config.get_value( \
            MISCELLANEOUS_SECTION_KEY, \
            FINISHED_LEVEL_STREAK_KEY, \
            0) as int

func set_failed_level_streak(streak: int) -> void:
    config.set_value( \
            MISCELLANEOUS_SECTION_KEY, \
            FAILED_LEVEL_STREAK_KEY, \
            streak)
    save_config()

func get_failed_level_streak() -> int:
    return config.get_value( \
            MISCELLANEOUS_SECTION_KEY, \
            FAILED_LEVEL_STREAK_KEY, \
            0) as int

func set_gave_feedback(gave_feedback: bool) -> void:
    config.set_value( \
            MISCELLANEOUS_SECTION_KEY, \
            GAVE_FEEDBACK_KEY, \
            gave_feedback)
    save_config()

func get_gave_feedback() -> bool:
    return config.get_value( \
            MISCELLANEOUS_SECTION_KEY, \
            GAVE_FEEDBACK_KEY, \
            false) as bool

func set_setting( \
        setting_key: String, \
        setting_value) -> void:
    config.set_value( \
            SETTINGS_SECTION_KEY, \
            setting_key, \
            setting_value)
    save_config()

func get_setting( \
        setting_key: String, \
        default = null):
    return config.get_value( \
                    SETTINGS_SECTION_KEY, \
                    setting_key) if \
            config.has_section_key( \
                    SETTINGS_SECTION_KEY, \
                    setting_key) else \
            default

func set_score_version(version: String) -> void:
    config.set_value( \
            VERSIONS_SECTION_KEY, \
            SCORE_VERSION_KEY, \
            version)
    save_config()

func get_score_version() -> String:
    return config.get_value( \
            VERSIONS_SECTION_KEY, \
            SCORE_VERSION_KEY, \
            "") as String

func set_level_version( \
        level_id: String, \
        version: String) -> void:
    config.set_value( \
            VERSIONS_SECTION_KEY, \
            level_id, \
            version)
    save_config()

func get_level_version(level_id: String) -> String:
    return config.get_value( \
            VERSIONS_SECTION_KEY, \
            level_id, \
            "") as String

func erase_all_scores() -> void:
    var sections := [
        HIGH_SCORES_SECTION_KEY,
        ALL_SCORES_SECTION_KEY,
        ALL_FINISHED_SCORES_SECTION_KEY,
    ]
    for section_key in sections:
        if config.has_section(section_key):
            config.erase_section(section_key)

func erase_level_state(level_id: String) -> void:
    var sections := [
        HIGH_SCORES_SECTION_KEY,
        HIGH_TIER_SECTION_KEY,
        TOTAL_PLAYS_SECTION_KEY,
        TOTAL_FALLS_SECTION_KEY,
        ALL_SCORES_SECTION_KEY,
        ALL_FINISHED_SCORES_SECTION_KEY,
        HAS_FINISHED_SECTION_KEY,
        HAS_THREE_LOOPED_SECTION_KEY,
    ]
    for section_key in sections:
        if config.has_section_key(section_key, level_id):
            config.erase_section_key( \
                    section_key, \
                    level_id)
    
    for key in config.get_section_keys(TOTAL_FALLS_ON_TIER_SECTION_KEY):
        if key.find(level_id + ":") == 0 and \
                config.has_section_key( \
                        TOTAL_FALLS_ON_TIER_SECTION_KEY, \
                        level_id):
            config.erase_section_key( \
                    TOTAL_FALLS_ON_TIER_SECTION_KEY, \
                    key)

func erase_all_state() -> void:
    for section in config.get_sections():
        if config.has_section(section):
            config.erase_section(section)
