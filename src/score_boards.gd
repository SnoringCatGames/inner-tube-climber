extends Node2D
class_name ScoreBoards

const CORNER_OFFSET := Vector2(10.0, 10.0)

func _enter_tree() -> void:
    position.y = max(CORNER_OFFSET.y, Utils.get_safe_area_margin_top())
    position.x = max(CORNER_OFFSET.x, Utils.get_safe_area_margin_left())

func set_height(height: int) -> void:
    $VBoxContainer/HeightPanel/HeightCount.text = str(height)

func set_lives(lives: int) -> void:
    $VBoxContainer/LivesPanel/LivesCount.text = str(lives)
