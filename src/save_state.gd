extends Node

const CONFIG_FILE_PATH := "user://settings.cfg"
const HIGH_SCORES_SECTION_KEY := "high_scores"
const SETTINGS_SECTION_KEY := "settings"

const DIFFICULTY_KEY := "difficulty"
const IS_GIVING_HAPTIC_FEEDBACK_KEY := "is_giving_haptic_feedback"
const IS_DEBUG_PANEL_SHOWN_KEY := "is_debug_panel_shown"
const ARE_MOBILE_CONTROLS_SHOWN_KEY := "are_mobile_controls_shown"
const MOBILE_CONTROL_VERSION_KEY := "mobile_control_version"
const IS_MULTIPLIER_COOLDOWN_INDICATOR_SHOWN_KEY := \
        "is_multiplier_cooldown_indicator_shown"
const IS_HEIGHT_INDICATOR_SHOWN_KEY := "is_height_indicator_shown"
const IS_SCORE_DISPLAY_SHOWN_KEY := "is_score_display_shown"
const IS_HEIGHT_DISPLAY_SHOWN_KEY := "is_height_display_shown"
const IS_LIVES_DISPLAY_SHOWN_KEY := "is_lives_display_shown"
const IS_TIER_RATIO_DISPLAY_SHOWN_KEY := "is_tier_ratio_display_shown"
const IS_MULTIPLIER_DISPLAY_SHOWN_KEY := "is_multiplier_display_shown"
const IS_SPEED_DISPLAY_SHOWN_KEY := "is_speed_display_shown"
const IS_MUSIC_ENABLED_KEY := "is_music_enabled"
const IS_SOUND_EFFECTS_ENABLED_KEY := "is_sound_effects_enabled"

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

func set_high_score_for_level( \
        level_id: String, \
        high_score: int) -> void:
    config.set_value( \
            HIGH_SCORES_SECTION_KEY, \
            level_id, \
            high_score)
    save_config()

func get_high_score_for_level(level_id: String) -> int:
    return config.get_value( \
            HIGH_SCORES_SECTION_KEY, \
            level_id, \
            0) as int

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
