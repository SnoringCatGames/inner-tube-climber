class_name DifficultyMode

enum {
    UNKNOWN,
    EASY,
    MODERATE,
    HARD,
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
        _:
            Utils.error("Invalid DifficultyMode: %s" % type)
            return "???"

static func get_string_type(string: String) -> int:
    match string:
        "UNKNOWN":
            return UNKNOWN
        "EASY":
            return EASY
        "MODERATE":
            return MODERATE
        "HARD":
            return HARD
        _:
            Utils.error("Invalid DifficultyMode: %s" % string)
            return UNKNOWN
