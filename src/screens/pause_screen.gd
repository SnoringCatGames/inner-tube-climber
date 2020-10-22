extends Screen
class_name PauseScreen

func _on_SettingsButton_pressed():
    Audio.button_press_sfx_player.play()
    Nav.set_screen_is_open( \
            ScreenType.SETTINGS, \
            true)

func _on_ExitLevelButton_pressed():
    Audio.button_press_sfx_player.play()
    Nav.set_screen_is_open( \
            ScreenType.MAIN_MENU, \
            true)

func _on_ResumeButton_pressed():
    Audio.button_press_sfx_player.play()
    Nav.close_current_screen()
    # FIXME: -------------- Unpause level?
