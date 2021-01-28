extends Node2D
class_name Main

func _enter_tree() -> void:
    Global.register_main(self)
    get_tree().root.set_pause_mode(Node.PAUSE_MODE_PROCESS)
    Nav.create_screens()

func _ready() -> void:
    Nav.open(ScreenType.SPLASH)
    
    Audio.play_sound(Sound.MENU_SELECT_FANCY)
    
    Time.set_timeout( \
            funcref(self, "_on_splash_finished"), \
            Constants.SPLASH_SCREEN_DURATION_SEC)

func _on_splash_finished() -> void:
    if Global.agreed_to_terms:
        Nav.open(ScreenType.MAIN_MENU)
    else:
        Nav.open(ScreenType.DATA_AGREEMENT)
    
    # Start playing the default music for the menu screen.
    Audio.cross_fade_music( \
            Audio.MAIN_MENU_MUSIC_PLAYER_INDEX, \
            true)

func _process(_delta_sec: float) -> void:
    if Input.is_action_just_pressed("screenshot"):
        Utils.take_screenshot()
