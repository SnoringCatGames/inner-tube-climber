class_name EffectAnimation

enum {
    JUMP_SIDEWAYS,
    JUMP_VERTICAL,
    LAND_SIDEWAYS,
    LAND_VERTICAL,
    WALK,
    WALL_BOUNCE,
    CEILING_HIT,
}

static func get_type_string(type: int) -> String:
    match type:
        JUMP_SIDEWAYS:
            return "JUMP_SIDEWAYS"
        JUMP_VERTICAL:
            return "JUMP_VERTICAL"
        LAND_SIDEWAYS:
            return "LAND_SIDEWAYS"
        LAND_VERTICAL:
            return "LAND_VERTICAL"
        WALK:
            return "WALK"
        WALL_BOUNCE:
            return "WALL_BOUNCE"
        CEILING_HIT:
            return "CEILING_HIT"
        _:
            Utils.error("Invalid EffectAnimation: %s" % type)
            return "???"
