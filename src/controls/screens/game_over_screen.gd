extends Screen
class_name GameOverScreen

const TYPE := ScreenType.GAME_OVER

func _init().(TYPE) -> void:
    pass

func _ready() -> void:
    Global.connect( \
            "display_resized", \
            self, \
            "_handle_display_resized")
    _handle_display_resized()

func _handle_display_resized() -> void:
    var viewport_size := get_viewport().size
    var is_wide_enough_to_put_title_in_nav_bar := viewport_size.x > 600
    $FullScreenPanel/VBoxContainer/NavBar.shows_logo = \
            is_wide_enough_to_put_title_in_nav_bar
#    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/CenterContainer/VBoxContainer/LogoControl.visible = \
#            !is_wide_enough_to_put_title_in_nav_bar
#    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/CenterContainer/VBoxContainer/Spacer2.visible = \
#            !is_wide_enough_to_put_title_in_nav_bar
    
    var is_tall_enough_to_have_large_animation := viewport_size.y > 600
    if is_tall_enough_to_have_large_animation:
        $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/CenterContainer/VBoxContainer/Control2 \
                .rect_min_size.y = 240
        $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/CenterContainer/VBoxContainer/Control2/StuckAnimationControl \
                .rect_scale = Vector2(4, 4)
        $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/CenterContainer/VBoxContainer/Control2/StuckAnimationControl \
                .rect_position.y = 120
    else:
        $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/CenterContainer/VBoxContainer/Control2 \
                .rect_min_size.y = 120
        $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/CenterContainer/VBoxContainer/Control2/StuckAnimationControl \
                .rect_scale = Vector2(2, 2)
        $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/CenterContainer/VBoxContainer/Control2/StuckAnimationControl \
                .rect_position.y = 60

