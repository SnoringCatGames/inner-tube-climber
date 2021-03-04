extends Node2D
class_name ScoreBoards

const CORNER_OFFSET := Vector2(14.0, 14.0)

func _enter_tree() -> void:
    position.y = max(CORNER_OFFSET.y, Utils.get_safe_area_margin_top())
    position.x = max(CORNER_OFFSET.x, Utils.get_safe_area_margin_left())
    update_displays()

func set_tier_ratio(tier_ratio) -> void:
    $VBoxContainer/TierRatioBoard.set_value_with_color_pulse(tier_ratio)

func set_height(height: int) -> void:
    $VBoxContainer/HeightBoard.animate_to_number(height)

func set_score(score: int) -> void:
    $VBoxContainer/ScoreBoard.animate_to_number(score)

func set_next_rank_at( \
        label_str: String, \
        value_str: String) -> void:
    $VBoxContainer/NextRankAtBoard/Label.text = label_str
    $VBoxContainer/NextRankAtBoard \
            .set_value_with_color_pulse(value_str)

func set_multiplier(multiplier: int) -> void:
    $VBoxContainer/MultiplierBoard \
            .set_value_with_color_pulse("x%s" % multiplier)

func set_speed(speed: int) -> void:
    $VBoxContainer/SpeedBoard.set_value_with_color_pulse("%s" % speed)

func set_lives(lives: int) -> void:
    $VBoxContainer/LivesBoard.set_value_with_color_pulse(str(lives))

func update_displays() -> void:
    $VBoxContainer/TierRatioBoard.visible = Global.is_tier_ratio_display_shown
    $VBoxContainer/HeightBoard.visible = Global.is_height_display_shown
    $VBoxContainer/ScoreBoard.visible = Global.is_score_display_shown
    $VBoxContainer/NextRankAtBoard.visible = \
            Global.is_next_rank_at_display_shown and \
            Global.difficulty_mode != DifficultyMode.EASY
    $VBoxContainer/MultiplierBoard.visible = Global.is_multiplier_display_shown
    $VBoxContainer/SpeedBoard.visible = Global.is_speed_display_shown
    $VBoxContainer/LivesBoard.visible = \
            Global.is_lives_display_shown and \
            Global.difficulty_mode != DifficultyMode.EASY
    $VBoxContainer/DebugTimeBoard.visible = \
            Global.is_debug_time_shown and \
            (Constants.DEBUG or Constants.PLAYTEST)
