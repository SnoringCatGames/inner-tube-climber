extends Screen
class_name MainMenuScreen

func _on_StartGameButton_pressed() -> void:
    Audio.button_press_sfx_player.play()
    Nav.set_screen_is_open( \
            ScreenType.LEVEL_SELECT, \
            true)

func _on_Settings_pressed():
    Audio.button_press_sfx_player.play()
    Nav.set_screen_is_open( \
            ScreenType.SETTINGS, \
            true)
