extends Screen
class_name DataAgreementScreen

const TYPE := ScreenType.DATA_AGREEMENT
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
            CenterContainer/VBoxContainer/AgreeButton as ShinyButton

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
