tool
extends Screen
class_name GameOverScreen

const TYPE := ScreenType.GAME_OVER
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := false
const INCLUDES_CENTER_CONTAINER := true

const RANK_TWEEN_DURATION_SEC := 0.6

var level_id: String
var score: String
var high_score: String
var tier_ratio: String 
var difficulty: String 
var time: String
var average_multiplier: String
var finished_level: bool
var three_looped_level: bool
var reached_new_high_score: bool
# Rank
var rank: int
var new_unlocked_levels: Array
var finished_last_three_levels: bool
var failed_last_three_levels: bool

var rank_tween: Tween

func _init().( \
        TYPE, \
        INCLUDES_STANDARD_HIERARCHY, \
        INCLUDES_NAV_BAR, \
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass

func _ready() -> void:
    rank_tween = Tween.new()
    add_child(rank_tween)
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

func _get_focused_button() -> ShinyButton:
    # FIXME: Conditionally suggest retry, if the next level is still unlocked.
    if true:
        return $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
                CenterContainer/VBoxContainer/VBoxContainer/ \
                SelectLevelButton as ShinyButton
    else:
        return $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
                CenterContainer/VBoxContainer/VBoxContainer/HBoxContainer/ \
                RetryButton as ShinyButton

func _update_stats() -> void:
    var unlocked_new_level_label := $FullScreenPanel/VBoxContainer/ \
            CenteredPanel/ScrollContainer/CenterContainer/VBoxContainer/ \
            VBoxContainer2/UnlockedNewLevelLabel
    var three_looped_level_label := $FullScreenPanel/VBoxContainer/ \
            CenteredPanel/ScrollContainer/CenterContainer/VBoxContainer/ \
            VBoxContainer2/ThreeLoopedLevelLabel
    var finished_level_label := $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/VBoxContainer2/ \
            FinishedLevelLabel
    var high_score_label := $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/VBoxContainer2/ \
            HighScoreLabel
    var control_list := $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/AccordionPanel/ \
            LabeledControlList
    var rank_animator := $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/Control2/ \
            RankAnimator
    var decrease_difficulty_button := $FullScreenPanel/VBoxContainer/ \
            CenteredPanel/ScrollContainer/CenterContainer/VBoxContainer/ \
            VBoxContainer2/DecreaseDifficultyButton
    var increase_difficulty_button := $FullScreenPanel/VBoxContainer/ \
            CenteredPanel/ScrollContainer/CenterContainer/VBoxContainer/ \
            VBoxContainer2/IncreaseDifficultyButton
    
    decrease_difficulty_button.visible = \
            Global.difficulty_mode != DifficultyMode.EASY and \
            failed_last_three_levels
    increase_difficulty_button.visible = \
            Global.difficulty_mode != DifficultyMode.HARD and \
            finished_last_three_levels
    
    rank_animator.rank = rank
    if rank != Rank.UNRANKED:
        rank_tween.interpolate_property( \
                rank_animator, \
                "rect_scale", \
                Vector2(15, 15), \
                Vector2.ONE, \
                RANK_TWEEN_DURATION_SEC, \
                Tween.TRANS_QUAD, \
                Tween.EASE_IN)
        rank_tween.start()
        Audio.play_sound(Sound.WALK_SNOW)
        Time.set_timeout( \
                funcref(Audio, "play_sound"), \
                RANK_TWEEN_DURATION_SEC, \
                [Sound.LAND])
    
    if !new_unlocked_levels.empty():
        unlocked_new_level_label.visible = true
        three_looped_level_label.visible = false
        finished_level_label.visible = false
    elif three_looped_level:
        unlocked_new_level_label.visible = false
        three_looped_level_label.visible = true
        finished_level_label.visible = false
    elif finished_level:
        unlocked_new_level_label.visible = false
        three_looped_level_label.visible = false
        finished_level_label.visible = true
    else:
        unlocked_new_level_label.visible = false
        three_looped_level_label.visible = false
        finished_level_label.visible = false
    
    high_score_label.visible = reached_new_high_score
    
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
        $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
                CenterContainer/VBoxContainer/Control2.rect_min_size.y = 240
        $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
                CenterContainer/VBoxContainer/Control2/StuckAnimationControl \
                .rect_scale = Vector2(4, 4)
        $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
                CenterContainer/VBoxContainer/Control2/StuckAnimationControl \
                .rect_position.y = 120
    else:
        $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
                CenterContainer/VBoxContainer/Control2.rect_min_size.y = 120
        $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
                CenterContainer/VBoxContainer/Control2/StuckAnimationControl \
                .rect_scale = Vector2(2, 2)
        $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
                CenterContainer/VBoxContainer/Control2/StuckAnimationControl \
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

func _on_DecreaseDifficultyButton_pressed():
    Global.give_button_press_feedback()
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer2/ \
            DecreaseDifficultyButton.visible = false
    match Global.difficulty_mode:
        DifficultyMode.HARD:
            Global.difficulty_mode = DifficultyMode.MODERATE
        DifficultyMode.MODERATE:
            Global.difficulty_mode = DifficultyMode.EASY
        _:
            Utils.error()
    SaveState.set_setting(SaveState.DIFFICULTY_KEY, Global.difficulty_mode)

func _on_IncreaseDifficultyButton_pressed():
    Global.give_button_press_feedback()
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer2/ \
            IncreaseDifficultyButton.visible = false
    match Global.difficulty_mode:
        DifficultyMode.EASY:
            Global.difficulty_mode = DifficultyMode.MODERATE
        DifficultyMode.MODERATE:
            Global.difficulty_mode = DifficultyMode.HARD
        _:
            Utils.error()
    SaveState.set_setting(SaveState.DIFFICULTY_KEY, Global.difficulty_mode)
