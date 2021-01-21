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
    OS.shell_open(Constants.SUPPORT_EMAIL_MAILTO + subject + body)
    
    get_tree().quit()

func _on_CancelButton_pressed():
    Global.give_button_press_feedback()
    Nav.close_current_screen()
