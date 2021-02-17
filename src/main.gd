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
    
    Nav.splash()

func _process(_delta_sec: float) -> void:
    if Input.is_action_just_pressed("screenshot"):
        Utils.take_screenshot()

func _set_window_debug_size_and_position() -> void:
    if Constants.DEBUG:
        # TODO: Useful for getting screenshots at specific resolutions.
        # Play Store
#        var window_size = Vector2(3840, 2160)
        # App Store: 6.5'' iPhone
#        var window_size = Vector2(2778, 1284)
        # App Store: 12.9'' iPad
#        var window_size = Vector2(2732, 2048)
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
