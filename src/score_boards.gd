extends Node2D
class_name ScoreBoards

func _enter_tree() -> void:
    position = Vector2( \
            5.0, \
            5.0)

func set_score(score: int) -> void:
    $VBoxContainer/ScorePanel/ScoreLabel.text = "Score: %d" % score

func set_falls(falls: int) -> void:
    $VBoxContainer/FallsPanel/FallsLabel.text = "Falls: %d" % falls
