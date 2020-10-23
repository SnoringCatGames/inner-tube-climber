extends Node2D
class_name TuberStuckAnimation

const DEFAULT_VERTICAL_OFFSET := -16.0

func _ready() -> void:
    $Sprite.scale = Vector2.ONE * Global.PLAYER_SIZE_MULTIPLIER
    position.y = DEFAULT_VERTICAL_OFFSET * Global.PLAYER_SIZE_MULTIPLIER
