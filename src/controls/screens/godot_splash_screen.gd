tool
extends Screen
class_name GodotSplashScreen

# NOTE: This is actually an extra splash screen. This is shown after the
#       built-in "boot splash" that Godot always renders. This is made to be a
#       pixel-perfect duplicate of Godot's built-in splash screen.

const TYPE := ScreenType.GODOT_SPLASH
const INCLUDES_STANDARD_HIERARCHY := false
const INCLUDES_NAV_BAR := false
const INCLUDES_CENTER_CONTAINER := false

const SPLASH_IMAGE_SIZE_DEFAULT := Vector2(900, 835)

func _init().( \
        TYPE, \
        INCLUDES_STANDARD_HIERARCHY, \
        INCLUDES_NAV_BAR, \
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass

func _enter_tree() -> void:
    if Engine.editor_hint:
        var viewport_size := Vector2(480, 480)
        var scale := viewport_size / SPLASH_IMAGE_SIZE_DEFAULT
        if scale.x > scale.y:
            scale.x = scale.y
        else:
            scale.y = scale.x
        var position := -SPLASH_IMAGE_SIZE_DEFAULT / 2
        $FullScreenPanel/Control/TextureRect.rect_scale = scale
        $FullScreenPanel/Control/TextureRect.rect_position = position
    else:
        Global.connect( \
                "display_resized", \
                self, \
                "_handle_display_resized")
        _handle_display_resized()

func _handle_display_resized() -> void:
    var viewport_size := get_viewport().size
    var scale := viewport_size / SPLASH_IMAGE_SIZE_DEFAULT
    if scale.x > scale.y:
        scale.x = scale.y
    else:
        scale.y = scale.x
    var position := -(SPLASH_IMAGE_SIZE_DEFAULT * scale) / 2
    $FullScreenPanel/Control/TextureRect.rect_scale = scale
    $FullScreenPanel/Control/TextureRect.rect_position = position
