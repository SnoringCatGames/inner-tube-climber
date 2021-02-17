class_name OpennessType

enum {
    UNKNOWN,
    WALLED,
    WALLED_LEFT,
    WALLED_RIGHT,
    OPEN,
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
        OPEN:
            return "OPEN"
        _:
            Utils.error("Invalid OpennessType: %s" % type)
            return "???"
