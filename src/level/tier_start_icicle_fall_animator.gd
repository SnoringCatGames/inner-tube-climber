extends Node2D
class_name TierStartIcicleFallAnimator

func fall() -> void:
    for child in get_children():
        child.fall()
