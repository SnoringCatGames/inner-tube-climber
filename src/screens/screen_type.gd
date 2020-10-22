class_name ScreenType

enum {
    UNKNOWN,
    MAIN_MENU,
    GAME,
    CREDITS,
    THIRD_PARTY_LICENSES,
    SETTINGS,
    PAUSE,
    LEVEL_SELECT,
}

static func get_type_string(type: int) -> String:
    match type:
        UNKNOWN:
            return "UNKNOWN"
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
        _:
            Utils.error("Invalid ScreenType: %s" % type)
            return "???"
