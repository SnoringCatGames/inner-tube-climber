extends Screen
class_name RateAppScreen

const TYPE := ScreenType.RATE_APP
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true

const NEXT_SCREEN_TYPE := ScreenType.GAME_OVER

func _init().( \
        TYPE, \
        INCLUDES_STANDARD_HIERARCHY, \
        INCLUDES_NAV_BAR, \
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass

func _get_focused_button() -> ShinyButton:
    return $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer2/RateAppButton as \
            ShinyButton

func _on_RateAppButton_pressed():
    Global.give_button_press_feedback()
    SaveState.set_gave_feedback(true)
    Nav.open(NEXT_SCREEN_TYPE)
    var app_store_url := \
            Constants.IOS_APP_STORE_URL if \
            Utils.get_is_ios_device() else \
            Constants.ANDROID_APP_STORE_URL
    OS.shell_open(app_store_url)

func _on_SendEmailButton_pressed():
    Global.give_button_press_feedback()
    Nav.open(NEXT_SCREEN_TYPE)
    var subject := \
            "?subject=Inner-Tube Climber question or feedback"
    OS.shell_open(Constants.SUPPORT_EMAIL_MAILTO + subject)

func _on_DontAskAgainButton_pressed():
    Global.give_button_press_feedback()
    SaveState.set_gave_feedback(true)
    Nav.open(NEXT_SCREEN_TYPE)

func _on_KeepPlayingButton_pressed():
    Global.give_button_press_feedback()
    Nav.open(NEXT_SCREEN_TYPE)
