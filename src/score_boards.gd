extends Node2D
class_name ScoreBoards

const CORNER_OFFSET := Vector2(10.0, 10.0)

func _enter_tree() -> void:
    position.y = max(CORNER_OFFSET.y, Utils.get_safe_area_margin_top())
    position.x = max(CORNER_OFFSET.x, Utils.get_safe_area_margin_left())

func set_tier_ratio( \
        tier_index: int, \
        tier_count: int) -> void:
    $VBoxContainer/TierRatioBoard.value = "%s / %s" % [tier_index, tier_count]

func set_height(height: int) -> void:
    $VBoxContainer/HeightBoard.value = str(height)

func set_score(score: float) -> void:
    $VBoxContainer/ScoreBoard.value = str(int(score))

func set_multiplier(multiplier: float) -> void:
    $VBoxContainer/MultiplierBoard.value = "%3.1f" % multiplier

func set_lives(lives: int) -> void:
    $VBoxContainer/LivesBoard.value = str(lives)
