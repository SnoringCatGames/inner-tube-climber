extends Screen
class_name CreditsScreen

const TYPE := ScreenType.CREDITS
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

func _on_third_party_licenses_button_pressed():
    Global.give_button_press_feedback()
    Nav.open(ScreenType.THIRD_PARTY_LICENSES)

func _on_snoring_cat_games_link_pressed():
    Global.give_button_press_feedback()
    OS.shell_open(Constants.SNORING_CAT_GAMES_URL)

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
    OS.shell_open(Utils.get_support_url())

func _on_DataDeletionButton_pressed():
    Global.give_button_press_feedback()
    Nav.open(ScreenType.CONFIRM_DATA_DELETION)
