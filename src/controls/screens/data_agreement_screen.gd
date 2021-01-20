extends Screen
class_name DataAgreementScreen

const TYPE := ScreenType.DATA_AGREEMENT

func _init().(TYPE) -> void:
    pass

func _on_PrivacyPolicyLink_pressed():
    Global.give_button_press_feedback()
    OS.shell_open(Constants.PRIVACY_POLICY_URL)

func _on_TermsAndConditionsLink_pressed():
    Global.give_button_press_feedback()
    OS.shell_open(Constants.TERMS_AND_CONDITIONS_URL)

func _on_AgreeButton_pressed():
    Global.give_button_press_feedback()
    Global.set_agreed_to_terms()
    Nav.open(ScreenType.MAIN_MENU)
