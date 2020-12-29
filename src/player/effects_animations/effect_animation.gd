class_name EffectAnimation

enum {
    JUMP,
}

static func get_type_string(type: int) -> String:
    match type:
        JUMP:
            return "JUMP"
        _:
            Utils.error("Invalid EffectAnimation: %s" % type)
            return "???"
