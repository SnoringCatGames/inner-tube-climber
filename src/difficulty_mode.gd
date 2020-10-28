class_name DifficultyMode

enum {
    UNKNOWN,
    EASY,
    MODERATE,
    HARD,
    DYNAMIC,
}

static func get_type_string(type: int) -> String:
    match type:
        UNKNOWN:
            return "UNKNOWN"
        EASY:
            return "EASY"
        MODERATE:
            return "MODERATE"
        HARD:
            return "HARD"
        DYNAMIC:
            return "DYNAMIC"
        _:
            Utils.error("Invalid DifficultyMode: %s" % type)
            return "???"
