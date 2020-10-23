tool
extends PanelContainer
class_name NavBar

export var text := "" setget _set_text

func _set_text(value: String) -> void:
    text = value
    $Header.text = text

func _on_BackButton_pressed():
    Audio.button_press_sfx_player.play()
    Nav.close_current_screen()
