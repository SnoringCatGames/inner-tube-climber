extends Screen
class_name CreditsScreen

const TYPE := ScreenType.CREDITS
const LEVI_URL := "https://levi.dev"
const GODOT_URL := "https://godotengine.org"

func _init().(TYPE) -> void:
    pass

func _on_third_party_licenses_button_pressed():
    Global.give_button_press_feedback()
    Nav.open(ScreenType.THIRD_PARTY_LICENSES)

func _on_levi_link_pressed():
    Global.give_button_press_feedback()
    OS.shell_open(LEVI_URL)

func _on_godot_link_pressed():
    Global.give_button_press_feedback()
    OS.shell_open(GODOT_URL)
