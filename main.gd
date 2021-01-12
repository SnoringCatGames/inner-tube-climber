extends Node2D
class_name Main

func _enter_tree() -> void:
    Global.register_main(self)
    get_tree().root.set_pause_mode(Node.PAUSE_MODE_PROCESS)
    Nav.create_screens()

func _ready() -> void:
    Nav.set_screen_is_open( \
            ScreenType.MAIN_MENU, \
            true)
    # Start playing the default music for the menu screen.
    Audio.cross_fade_music( \
            Audio.MAIN_MENU_MUSIC_PLAYER_INDEX, \
            true)
    
    login()

func _process(_delta_sec: float) -> void:
    if Input.is_action_just_pressed("screenshot"):
        Utils.take_screenshot()

func login() -> void:
    facebook.connect( \
            "login_success", \
            self, \
            "_on_facebook_login_success")
    facebook.connect( \
            "login_cancelled", \
            self, \
            "_on_facebook_login_cancelled")
    facebook.connect( \
            "login_failed", \
            self, \
            "_on_facebook_login_failed")
    facebook.login(["email"])

func _on_facebook_login_success(access_token: String) -> void:
    auth.connect( \
            "logged_in", \
            self, \
            "_on_firebase_login_success")
    auth.login_facebook(access_token)

func _on_firebase_login_success() -> void:
    print("Firebase+Facebook login successful!")

# FIXME: Handle failure cases.
func _on_facebook_login_cancelled() -> void:
    pass
func _on_facebook_login_failed() -> void:
    pass
