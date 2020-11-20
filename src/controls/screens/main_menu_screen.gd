extends Screen
class_name MainMenuScreen

const TYPE := ScreenType.MAIN_MENU

func _init().(TYPE) -> void:
    pass

func _on_StartGameButton_pressed() -> void:
    Global.give_button_press_feedback()
    Nav.set_screen_is_open( \
            ScreenType.LEVEL_SELECT, \
            true)

func _on_Settings_pressed():
    Global.give_button_press_feedback()
    Nav.set_screen_is_open( \
            ScreenType.SETTINGS, \
            true)

func _on_About_pressed():
    Global.give_button_press_feedback()
    Nav.set_screen_is_open( \
            ScreenType.CREDITS, \
            true)
