class_name ScreenType

enum {
    UNKNOWN,
    GODOT_SPLASH,
    SNORING_CAT_SPLASH,
    MAIN_MENU,
    GAME,
    CREDITS,
    THIRD_PARTY_LICENSES,
    SETTINGS,
    PAUSE,
    LEVEL_SELECT,
    DATA_AGREEMENT,
    RATE_APP,
    GAME_OVER,
    CONFIRM_DATA_DELETION,
    NOTIFICATION,
}

static func get_type_string(type: int) -> String:
    match type:
        UNKNOWN:
            return "UNKNOWN"
        GODOT_SPLASH:
            return "GODOT_SPLASH"
        SNORING_CAT_SPLASH:
            return "SNORING_CAT_SPLASH"
        MAIN_MENU:
            return "MAIN_MENU"
        GAME:
            return "GAME"
        CREDITS:
            return "CREDITS"
        THIRD_PARTY_LICENSES:
            return "THIRD_PARTY_LICENSES"
        SETTINGS:
            return "SETTINGS"
        PAUSE:
            return "PAUSE"
        LEVEL_SELECT:
            return "LEVEL_SELECT"
        DATA_AGREEMENT:
            return "DATA_AGREEMENT"
        RATE_APP:
            return "RATE_APP"
        GAME_OVER:
            return "GAME_OVER"
        CONFIRM_DATA_DELETION:
            return "CONFIRM_DATA_DELETION"
        NOTIFICATION:
            return "NOTIFICATION"
        _:
            Utils.error("Invalid ScreenType: %s" % type)
            return "???"
