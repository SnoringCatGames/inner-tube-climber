extends Screen
class_name PauseScreen

const TYPE := ScreenType.PAUSE

func _init().(TYPE) -> void:
    pass

func _on_SettingsButton_pressed():
    Global.give_button_press_feedback()
    Nav.set_screen_is_open( \
            ScreenType.SETTINGS, \
            true)

func _on_ExitLevelButton_pressed():
    Global.give_button_press_feedback()
    Nav.set_screen_is_open( \
            ScreenType.MAIN_MENU, \
            true)

func _on_ResumeButton_pressed():
    Global.give_button_press_feedback()
    Nav.close_current_screen()
    # FIXME: -------------- Unpause level?
