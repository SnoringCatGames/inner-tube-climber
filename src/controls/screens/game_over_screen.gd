tool
extends Screen
class_name GameOverScreen

const TYPE := ScreenType.GAME_OVER
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := false
const INCLUDES_CENTER_CONTAINER := true

const RANK_TWEEN_DURATION_SEC := 0.6
const RANK_TWEEN_DELAY_SEC := 1.2
const RANK_TWEEN_SCALE_START := Vector2(15, 15)

var level_id: String
var score: String
var high_score: String
var tier_ratio: String 
var tiers_remaining_count: int
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

func _enter_tree() -> void:
    rank_tween = Tween.new()
    add_child(rank_tween)

func _ready() -> void:
    Global.connect( \
            "display_resized", \
            self, \
            "_handle_display_resized")
    _handle_display_resized()
    _update_stats()

func _on_activated() -> void:
    ._on_activated()
    Audio.play_music(Music.GAME_OVER_MUSIC_TYPE)
    _update_stats()

func _get_focused_button() -> ShinyButton:
    # Conditionally suggest retry, if the player didn't finish the level.
    if finished_level:
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
    var tiers_remaining_label := $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/VBoxContainer2/ \
            TiersRemainingLabel
    var control_list := $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/AccordionPanel/ \
            LabeledControlList
    var rank_animator := $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/Control2/ \
            RankWrapper/Node2D/RankAnimator
    var three_loop_icon := $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/Control2/ \
            RankWrapper/Node2D/ThreeLoopIcon
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
    rank_animator.visible = false
    if rank != Rank.UNRANKED:
        Time.set_timeout( \
                funcref(rank_animator, "set_visible"), \
                RANK_TWEEN_DELAY_SEC, \
                [true])
        rank_tween.interpolate_property( \
                rank_animator, \
                "rect_scale", \
                RANK_TWEEN_SCALE_START, \
                Vector2.ONE, \
                RANK_TWEEN_DURATION_SEC, \
                Tween.TRANS_QUAD, \
                Tween.EASE_IN, \
                RANK_TWEEN_DELAY_SEC)
        rank_tween.start()
        Audio.play_sound(Sound.WALK_SNOW)
        Time.set_timeout( \
                funcref(Audio, "play_sound"), \
                RANK_TWEEN_DURATION_SEC + RANK_TWEEN_DELAY_SEC, \
                [Sound.LAND])
    
    three_loop_icon.visible = false
    if three_looped_level:
        var delay := RANK_TWEEN_DELAY_SEC + RANK_TWEEN_DURATION_SEC / 2.0
        Time.set_timeout( \
                funcref(three_loop_icon, "set_visible"), \
                delay, \
                [true])
        rank_tween.interpolate_property( \
                three_loop_icon, \
                "rect_scale", \
                RANK_TWEEN_SCALE_START, \
                Vector2.ONE, \
                RANK_TWEEN_DURATION_SEC, \
                Tween.TRANS_QUAD, \
                Tween.EASE_IN, \
                delay)
        rank_tween.start()
        Audio.play_sound(Sound.WALK_SNOW)
        Time.set_timeout( \
                funcref(Audio, "play_sound"), \
                RANK_TWEEN_DURATION_SEC + delay, \
                [Sound.LAND])
    
    if !new_unlocked_levels.empty():
        unlocked_new_level_label.visible = true
        three_looped_level_label.visible = false
        finished_level_label.visible = false
        tiers_remaining_label.visible = false
    elif three_looped_level:
        unlocked_new_level_label.visible = false
        three_looped_level_label.visible = true
        finished_level_label.visible = false
        tiers_remaining_label.visible = false
    elif finished_level:
        unlocked_new_level_label.visible = false
        three_looped_level_label.visible = false
        finished_level_label.visible = true
        tiers_remaining_label.visible = false
    else:
        unlocked_new_level_label.visible = false
        three_looped_level_label.visible = false
        finished_level_label.visible = false
        tiers_remaining_label.visible = true
        
        tiers_remaining_label.text = \
                "Try clearing %d more tiers to finish the level!" % \
                tiers_remaining_count
    
    high_score_label.visible = reached_new_high_score
    
    var score_for_next_rank_str: String = \
            LevelConfig.get_score_for_next_rank_str(level_id, rank) if \
            level_id != "" else \
            ""
    
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
            label = "Next rank at:",
            type = LabeledControlItemType.TEXT,
            text = score_for_next_rank_str,
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

func _hide_rank_and_three_loop() -> void:
    var rank_animator := $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/Control2/ \
            RankWrapper/Node2D/RankAnimator
    var three_loop_icon := $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/Control2/ \
            RankWrapper/Node2D/ThreeLoopIcon
    rank_animator.visible = false
    three_loop_icon.visible = false

func _on_SelectLevelButton_pressed():
    Global.give_button_press_feedback()
    Audio.play_music(Music.MAIN_MENU_MUSIC_TYPE)
    _hide_rank_and_three_loop()
    Nav.open(ScreenType.LEVEL_SELECT)

func _on_HomeButton_pressed():
    Global.give_button_press_feedback()
    Audio.play_music(Music.MAIN_MENU_MUSIC_TYPE)
    _hide_rank_and_three_loop()
    Nav.open(ScreenType.MAIN_MENU)

func _on_RetryButton_pressed():
    Global.give_button_press_feedback(true)
    _hide_rank_and_three_loop()
    Nav.open(ScreenType.GAME, true)
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
