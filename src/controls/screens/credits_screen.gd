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
    var subject := \
            "?subject=Inner-Tube Climber question or feedback"
    var status := OS.shell_open(Constants.SUPPORT_EMAIL_MAILTO + subject)
    if status != OK:
        Nav.open(ScreenType.NOTIFICATION, false, {
            header_text = "Send email manually",
            is_back_button_shown = false,
            body_text = ("There was a problem automatically opening the " + \
                    "mail client on your device. Please manually send " + \
                    "an email to support@snoringcat.games."),
            close_button_text = "OK",
        })

func _on_DataDeletionButton_pressed():
    Global.give_button_press_feedback()
    Nav.open(ScreenType.CONFIRM_DATA_DELETION)
