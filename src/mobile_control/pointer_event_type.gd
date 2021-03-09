class_name PointerEventType

enum {
    UNKNOWN,
    DOWN,
    UP,
    DRAG,
}

static func get_pointer_event_type_string(type: int) -> String:
    match type:
        UNKNOWN:
            return "UNKNOWN"
        DOWN:
            return "DOWN"
        UP:
            return "UP"
        DRAG:
            return "DRAG"
        _:
            Utils.static_error()
            return "???"
