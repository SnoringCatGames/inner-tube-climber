extends Node2D
class_name Main

func _enter_tree() -> void:
    Global.register_main(self)
    get_tree().root.set_pause_mode(Node.PAUSE_MODE_PROCESS)
    Nav.create_screens()

func _ready() -> void:
    _set_window_debug_size_and_position()
    
    if Utils.get_is_browser():
        JavaScript.eval("window.onGameReady()")
    
    if Constants.DEBUG and Constants.DEBUG_TIER != "":
        _skip_to_debug_tier()
    else:
        Nav.splash()

func _process(_delta_sec: float) -> void:
    if Constants.DEBUG or Constants.PLAYTEST:
        if Input.is_action_just_pressed("screenshot"):
            Utils.take_screenshot()
        if Input.is_action_just_pressed("one_up"):
            Global.level.add_life()

func _skip_to_debug_tier() -> void:
    Global.give_button_press_feedback(true)
    Nav.open(ScreenType.GAME, true)
    var level_config: Dictionary = LevelConfig._inflated_levels["1"]
    level_config.tiers = [Constants.DEBUG_TIER]
    Nav.screens[ScreenType.GAME].start_level("1")

func _set_window_debug_size_and_position() -> void:
    if Constants.DEBUG:
        # TODO: Useful for getting screenshots at specific resolutions.
        # Play Store
#        var window_size = Vector2(3840, 2160)
        # App Store: 6.5'' iPhone
#        var window_size = Vector2(2778, 1284)
        # App Store: 12.9'' iPad
#        var window_size = Vector2(2732, 2048)
        # Default
#        var window_size := Vector2(480.0, 480.0)
        # Just show as full screen.
        var window_size := Vector2.INF
        
        if window_size == Vector2.INF:
            if OS.get_screen_count() > 1:
                # Show the game window on the other window, rather than
                # over-top the editor.
                OS.current_screen = \
                        (OS.current_screen + 1) % OS.get_screen_count()
                OS.window_fullscreen = true
                OS.window_borderless = true
        else:
            OS.window_size = window_size
