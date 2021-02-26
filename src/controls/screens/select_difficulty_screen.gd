extends Screen
class_name SelectDifficultyScreen

const TYPE := ScreenType.SELECT_DIFFICULTY
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true

func _init().( \
        TYPE, \
        INCLUDES_STANDARD_HIERARCHY, \
        INCLUDES_NAV_BAR, \
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass

func _get_focused_button() -> ShinyButton:
    return $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/ModerateButton as ShinyButton

func _on_EasyButton_pressed():
    _on_difficulty_selected(DifficultyMode.EASY)

func _on_ModerateButton_pressed():
    _on_difficulty_selected(DifficultyMode.MODERATE)

func _on_HardButton_pressed():
    _on_difficulty_selected(DifficultyMode.HARD)

func _on_difficulty_selected(difficulty: int) -> void:
    Global.give_button_press_feedback()
    Global.difficulty_mode = difficulty
    SaveState.set_setting(SaveState.DIFFICULTY_KEY, Global.difficulty_mode)
    Global.set_selected_difficulty()
    Nav.close_current_screen()
    Nav.open(ScreenType.LEVEL_SELECT)
