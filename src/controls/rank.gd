class_name Rank

enum {
    UNRANKED,
    BRONZE,
    SILVER,
    GOLD,
}

static func get_type_string(type: int) -> String:
    match type:
        UNRANKED:
            return "UNRANKED"
        BRONZE:
            return "BRONZE"
        SILVER:
            return "SILVER"
        GOLD:
            return "GOLD"
        _:
            Utils.error("Invalid Rank: %s" % type)
            return "???"
