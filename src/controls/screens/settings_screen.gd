extends Screen
class_name SettingsScreen

const TYPE := ScreenType.SETTINGS

func _init().(TYPE) -> void:
    pass

func _on_CreditsButton_pressed() -> void:
    Global.give_button_press_feedback()
    Nav.set_screen_is_open( \
            ScreenType.CREDITS, \
            true)
