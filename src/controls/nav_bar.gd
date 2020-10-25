tool
extends PanelContainer
class_name NavBar

export var text := "" setget _set_text

func _enter_tree() -> void:
    $MarginContainer.set( \
            "custom_constants/margin_top", \
            Utils.get_safe_area_margin_top())
    $MarginContainer/BackButton.rect_position.x += \
            Utils.get_safe_area_margin_left()

func _set_text(value: String) -> void:
    text = value
    $MarginContainer/Header.text = text

func _on_BackButton_pressed():
    Global.give_button_press_feedback()
    Nav.close_current_screen()
