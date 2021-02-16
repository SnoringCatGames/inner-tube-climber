extends Node2D
class_name Main

func _enter_tree() -> void:
    Global.register_main(self)
    get_tree().root.set_pause_mode(Node.PAUSE_MODE_PROCESS)
    Nav.create_screens()

func _ready() -> void:
    # FIXME: Remove: Useful for getting screenshots at specific resolutions.
    # Play Store
#    OS.window_size = Vector2(3840, 2160)
    # App Store: 6.5'' iPhone
#    OS.window_size = Vector2(2778, 1284)
    # App Store: 12.9'' iPad
#    OS.window_size = Vector2(2732, 2048)
    
    if OS.get_name() == "HTML5":
        JavaScript.eval("window.onGameReady()")
    
    Nav.splash()

func _process(_delta_sec: float) -> void:
    if Input.is_action_just_pressed("screenshot"):
        Utils.take_screenshot()
