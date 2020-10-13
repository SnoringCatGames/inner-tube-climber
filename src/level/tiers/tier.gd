tool
extends Node2D
class_name Tier

# NOTE: Keep in-sync with the values in openness_type.gd.
enum OpennessType {
    UNKNOWN,
    WALLED,
    WALLED_LEFT,
    WALLED_RIGHT,
    OPEN_WITHOUT_HORIZONTAL_PAN,
    OPEN_WITH_HORIZONTAL_PAN,
}

export(OpennessType) var openness_type := OpennessType.UNKNOWN
