extends Screen
class_name MainMenuScreen

const TYPE := ScreenType.MAIN_MENU

func _init().(TYPE) -> void:
    pass

func _on_StartGameButton_pressed() -> void:
    Global.give_button_press_feedback()
    Nav.open(ScreenType.LEVEL_SELECT)

func _on_Settings_pressed():
    Global.give_button_press_feedback()
    Nav.open(ScreenType.SETTINGS)

func _on_About_pressed():
    Global.give_button_press_feedback()
    Nav.open(ScreenType.CREDITS)
