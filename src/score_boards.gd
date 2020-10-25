extends Node2D
class_name ScoreBoards

const CORNER_OFFSET := Vector2(10.0, 10.0)

func _enter_tree() -> void:
    position.y = max(CORNER_OFFSET.y, Utils.get_safe_area_margin_top())
    position.x = max(CORNER_OFFSET.x, Utils.get_safe_area_margin_left())

func set_score(score: int) -> void:
    $VBoxContainer/ScorePanel/ScoreLabel.text = "Score: %d" % score

func set_falls(falls: int) -> void:
    $VBoxContainer/FallsPanel/FallsLabel.text = "Falls: %d" % falls
