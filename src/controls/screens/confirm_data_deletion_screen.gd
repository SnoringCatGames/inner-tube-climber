extends Screen
class_name ConfirmDataDeletionScreen

const TYPE := ScreenType.CONFIRM_DATA_DELETION
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

func _get_focused_button() -> ShinyButton:
    return $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/CancelButton as ShinyButton

func _on_ConfirmButton_pressed():
    Global.give_button_press_feedback()
    
    SaveState.erase_all_state()
    
    # Erase user files.
    Utils.clear_directory("user://")
    
    var subject := \
            "?subject=DATA-DELETION REQUEST: Inner-Tube Climber: " + \
            str(Analytics.client_id)
    var body := \
            "&body=(Don't change the subject! The client ID number must " + \
            "be included for us to know which data to delete.)"
    var status := OS.shell_open( \
            Constants.SUPPORT_EMAIL_MAILTO + subject + body)
    if status != OK:
        OS.set_clipboard("Client ID: %s" % Analytics.client_id)
        Nav.open(ScreenType.NOTIFICATION, false, {
            header_text = "Send email manually",
            is_back_button_shown = false,
            body_text = ("There was a problem automatically opening the " + \
                    "mail client on your device. You need to manually send " + \
                    "an email to support@snoringcat.games. Include this " + \
                    "client ID number, so we know which data to delete: %s " + \
                    "(including a screenshot of this page will also work).") % \
                    str(Analytics.client_id),
            close_button_text = "Close app",
            close_callback = funcref(self, "quit"),
            next_screen = ScreenType.DATA_AGREEMENT,
        })
    else:
        quit()

func quit() -> void:
    get_tree().quit()
    Nav.open(ScreenType.DATA_AGREEMENT)

func _on_CancelButton_pressed():
    Global.give_button_press_feedback()
    Nav.close_current_screen()
