extends Screen
class_name CreditsScreen

const TYPE := ScreenType.CREDITS

func _init().(TYPE) -> void:
    pass

func _on_third_party_licenses_button_pressed():
    Global.give_button_press_feedback()
    Nav.open(ScreenType.THIRD_PARTY_LICENSES)

func _on_levi_link_pressed():
    Global.give_button_press_feedback()
    OS.shell_open(Constants.LEVI_URL)

func _on_godot_link_pressed():
    Global.give_button_press_feedback()
    OS.shell_open(Constants.GODOT_URL)

func _on_PrivacyPolicyLink_pressed():
    Global.give_button_press_feedback()
    OS.shell_open(Constants.PRIVACY_POLICY_URL)

func _on_TermsAndConditionsLink_pressed():
    Global.give_button_press_feedback()
    OS.shell_open(Constants.TERMS_AND_CONDITIONS_URL)

func _on_SupportLink_pressed():
    Global.give_button_press_feedback()
    var subject := \
            "?subject=Inner-Tube Climber question or feedback"
    OS.shell_open(Constants.SUPPORT_EMAIL_MAILTO + subject)

func _on_DataDeletionButton_pressed():
    Global.give_button_press_feedback()
    Nav.open(ScreenType.CONFIRM_DATA_DELETION)
