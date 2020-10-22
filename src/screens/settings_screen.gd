extends Screen
class_name SettingsScreen

func _on_CreditsButton_pressed() -> void:
    Audio.button_press_sfx_player.play()
    Nav.set_screen_is_open( \
            ScreenType.CREDITS, \
            true)
