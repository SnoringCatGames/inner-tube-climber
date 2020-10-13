class_name OpennessType

enum {
    UNKNOWN,
    WALLED,
    WALLED_LEFT,
    WALLED_RIGHT,
    OPEN_WITHOUT_HORIZONTAL_PAN,
    OPEN_WITH_HORIZONTAL_PAN,
}

static func get_type_string(type: int) -> String:
    match type:
        UNKNOWN:
            return "UNKNOWN"
        WALLED:
            return "WALLED"
        WALLED_LEFT:
            return "WALLED_LEFT"
        WALLED_RIGHT:
            return "WALLED_RIGHT"
        OPEN_WITHOUT_HORIZONTAL_PAN:
            return "OPEN_WITHOUT_HORIZONTAL_PAN"
        OPEN_WITH_HORIZONTAL_PAN:
            return "OPEN_WITH_HORIZONTAL_PAN"
        _:
            Utils.error("Invalid OpennessType: %s" % type)
            return "???"
