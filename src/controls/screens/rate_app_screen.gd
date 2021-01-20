extends Screen
class_name RateAppScreen

const TYPE := ScreenType.RATE_APP

func _init().(TYPE) -> void:
    pass

func _on_RateAppButton_pressed():
    Global.give_button_press_feedback()
    Nav.open(ScreenType.LEVEL_SELECT)
    var app_store_url := \
            Constants.IOS_APP_STORE_URL if \
            Utils.get_is_ios_device() else \
            Constants.ANDROID_APP_STORE_URL
    OS.shell_open(app_store_url)

func _on_SendEmailButton_pressed():
    Global.give_button_press_feedback()
    Nav.open(ScreenType.LEVEL_SELECT)
    OS.shell_open(Constants.SUPPORT_EMAIL)

func _on_KeepPlayingButton_pressed():
    Global.give_button_press_feedback()
    Nav.open(ScreenType.LEVEL_SELECT)
