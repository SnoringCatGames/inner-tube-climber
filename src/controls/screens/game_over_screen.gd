tool
extends Screen
class_name GameOverScreen

const TYPE := ScreenType.GAME_OVER
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true

var level_id: String
var score: String
var high_score: String
var tier_ratio: String 
var difficulty: String 
var time: String
var average_multiplier: String

func _init().( \
        TYPE, \
        INCLUDES_STANDARD_HIERARCHY, \
        INCLUDES_NAV_BAR, \
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass

func _ready() -> void:
    Global.connect( \
            "display_resized", \
            self, \
            "_handle_display_resized")
    _handle_display_resized()
    _update_stats()

func _on_activated() -> void:
    ._on_activated()
    Audio.cross_fade_music(Audio.GAME_OVER_MUSIC_PLAYER_INDEX)
    _update_stats()

func _update_stats() -> void:
    var control_list := $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/LabeledControlList
    
    control_list.items = [
        {
            label = "Level:",
            type = LabeledControlItemType.TEXT,
            text = level_id,
        },
        {
            label = "Score:",
            type = LabeledControlItemType.TEXT,
            text = score,
        },
        {
            label = "High score:",
            type = LabeledControlItemType.TEXT,
            text = high_score,
        },
        {
            label = "Avg. multiplier:",
            type = LabeledControlItemType.TEXT,
            text = average_multiplier,
        },
        {
            label = "Tier:",
            type = LabeledControlItemType.TEXT,
            text = tier_ratio,
        },
        {
            label = "Difficulty:",
            type = LabeledControlItemType.TEXT,
            text = difficulty,
        },
        {
            label = "Time:",
            type = LabeledControlItemType.TEXT,
            text = time,
        },
    ]

func _handle_display_resized() -> void:
    var viewport_size := get_viewport().size
    
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

func _on_SelectLevelButton_pressed():
    Global.give_button_press_feedback()
    Audio.cross_fade_music(Audio.MAIN_MENU_MUSIC_PLAYER_INDEX)
    Nav.open(ScreenType.LEVEL_SELECT)

func _on_HomeButton_pressed():
    Global.give_button_press_feedback()
    Audio.cross_fade_music(Audio.MAIN_MENU_MUSIC_PLAYER_INDEX)
    Nav.open(ScreenType.MAIN_MENU)

func _on_RetryButton_pressed():
    Global.give_button_press_feedback(true)
    Nav.open(ScreenType.GAME)
    Nav.screens[ScreenType.GAME].start_level(level_id)
