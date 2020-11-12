extends Node2D
class_name ScoreBoards

const CORNER_OFFSET := Vector2(10.0, 10.0)

func _enter_tree() -> void:
    position.y = max(CORNER_OFFSET.y, Utils.get_safe_area_margin_top())
    position.x = max(CORNER_OFFSET.x, Utils.get_safe_area_margin_left())

func set_tier_ratio( \
        tier_index: int, \
        tier_count: int) -> void:
    $VBoxContainer/TierRatioBoard \
            .set_value_with_color_pulse("%s / %s" % [tier_index, tier_count])

func set_height(height: int) -> void:
    $VBoxContainer/HeightBoard.animate_to_number(height)

func set_score(score: int) -> void:
    $VBoxContainer/ScoreBoard.animate_to_number(score)

func set_multiplier(multiplier: int) -> void:
    $VBoxContainer/MultiplierBoard.set_value_with_color_pulse("x%s" % multiplier)

func set_speed(speed: int) -> void:
    $VBoxContainer/SpeedBoard.set_value_with_color_pulse("%s" % speed)

func set_lives(lives: int) -> void:
    $VBoxContainer/LivesBoard.set_value_with_color_pulse(str(lives))
