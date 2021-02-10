extends Screen
class_name NotificationScreen

const TYPE := ScreenType.NOTIFICATION
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true

func _init().( \
        TYPE, \
        INCLUDES_STANDARD_HIERARCHY, \
        INCLUDES_NAV_BAR, \
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass

func set_params(params) -> void:
    .set_params(params)
    
    if params == null:
        return
    
    var nav_bar := $FullScreenPanel/VBoxContainer/NavBar
    var body_text := $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/BodyText
    var link := $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/NotificationLink
    var close_button := $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/CloseButton
    
    assert(params.has("header_text"))
    nav_bar.text = params["header_text"]
    assert(params.has("is_back_button_shown"))
    nav_bar.shows_back = params["is_back_button_shown"]
    assert(params.has("body_text"))
    body_text.text = params["body_text"]
    assert(params.has("close_button_text"))
    close_button.text = params["close_button_text"]
    
    if params.has("link_text") or \
            params.has("link_href"):
        assert(params.has("link_text"))
        assert(params.has("link_href"))
        link.visible = true
        link.text = params["link_text"]
    else:
        link.visible = false

func _get_focused_button() -> ShinyButton:
    return $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/CloseButton as ShinyButton

func _on_CloseButton_pressed():
    Global.give_button_press_feedback()
    
    if params.has("close_callback"):
        params["close_callback"].call_func()
    
    if params.has("next_screen"):
        Nav.open(params["next_screen"])
    else:
        Nav.close_current_screen()

func _on_NotificationLink_pressed():
    Global.give_button_press_feedback()
    
    OS.shell_open(params["link_href"])
