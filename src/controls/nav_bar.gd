tool
extends PanelContainer
class_name NavBar

export var text := "" setget _set_text
export var shows_back := true setget _set_shows_back,_get_shows_back
export var shows_about := false setget _set_shows_about,_get_shows_about
export var shows_settings := false setget _set_shows_settings,_get_shows_settings
export var shows_logo := false setget _set_shows_logo,_get_shows_logo
export var shows_game_over := false setget _set_shows_game_over,_get_shows_game_over

func _enter_tree() -> void:
    $MarginContainer.set( \
            "custom_constants/margin_top", \
            Utils.get_safe_area_margin_top())
    $MarginContainer/BackButton.rect_position.x += \
            Utils.get_safe_area_margin_left()
    $MarginContainer/AboutButton.rect_position.x += \
            Utils.get_safe_area_margin_left()
    $MarginContainer/SettingsButton.rect_position.x -= \
            Utils.get_safe_area_margin_right()
    _set_shows_back(shows_back)
    _set_shows_about(shows_about)
    _set_shows_settings(shows_settings)
    _set_shows_logo(shows_logo)
    _set_shows_game_over(shows_game_over)

func _set_text(value: String) -> void:
    text = value
    if $MarginContainer/Header != null:
        $MarginContainer/Header.text = text

func _set_shows_back(value: bool) -> void:
    shows_back = value
    if $MarginContainer/BackButton != null:
        $MarginContainer/BackButton.visible = shows_back

func _get_shows_back() -> bool:
    return shows_back

func _set_shows_about(value: bool) -> void:
    shows_about = value
    if $MarginContainer/AboutButton != null:
        $MarginContainer/AboutButton.visible = shows_about

func _get_shows_about() -> bool:
    return shows_about

func _set_shows_settings(value: bool) -> void:
    shows_settings = value
    if $MarginContainer/SettingsButton != null:
        $MarginContainer/SettingsButton.visible = shows_settings

func _get_shows_settings() -> bool:
    return shows_settings

func _set_shows_logo(value: bool) -> void:
    shows_logo = value
    if $MarginContainer/LogoControl != null:
        $MarginContainer/LogoControl.visible = shows_logo

func _get_shows_logo() -> bool:
    return shows_logo

func _set_shows_game_over(value: bool) -> void:
    shows_game_over = value
    if $MarginContainer/GameOverControl != null:
        $MarginContainer/GameOverControl.visible = shows_game_over

func _get_shows_game_over() -> bool:
    return shows_game_over

func _on_BackButton_pressed():
    Global.give_button_press_feedback()
    Nav.close_current_screen()

func _on_AboutButton_pressed():
    Global.give_button_press_feedback()
    Nav.open(ScreenType.CREDITS)

func _on_SettingsButton_pressed():
    Global.give_button_press_feedback()
    if Global.level != null:
        var description := \
                "The level must be restarted in order to change settings." + \
                "\n\nAre you sure you want to restart the level?"
        Nav.open( \
                ScreenType.NOTIFICATION, \
                false, \
                {
                    header_text = "Reset level?",
                    is_back_button_shown = true,
                    body_text = description,
                    close_button_text = "Yes",
                    body_alignment = BoxContainer.ALIGN_BEGIN,
                    next_screen = ScreenType.SETTINGS,
                })
    else:
        Nav.open(ScreenType.SETTINGS)
