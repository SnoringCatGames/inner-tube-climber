tool
extends Control
class_name LevelSelectItem

signal toggled

const HEADER_HEIGHT := 56.0
const PADDING := Vector2(16.0, 8.0)
const RANK_ICON_SIZE_DEFAULT := RankAnimator.SMALL_SIZE
const RANK_ICON_SCALE := Vector2(1.0, 1.0)
const LOCKED_OPACITY := 0.6
const FADE_TWEEN_DURATION_SEC := 0.3
const LOCK_LOW_PART_DELAY_SEC := 0.7
const LOCK_HIGH_PART_DELAY_SEC := 0.15

export var level_id := "" setget _set_level_id,_get_level_id
export var is_open: bool setget _set_is_open,_get_is_open

func _ready() -> void:
    _init_children()
    call_deferred("update")

func _process(_delta_sec: float) -> void:
    rect_min_size.y = $AccordionPanel.rect_min_size.y

func _init_children() -> void:
    var header_size := Vector2(rect_size.x, HEADER_HEIGHT)
    
    $HeaderWrapper/LockedWrapper.rect_min_size = header_size
    
    $HeaderWrapper/Header.rect_min_size = header_size
    $HeaderWrapper/Header.connect("pressed", self, "_on_header_pressed")
    $HeaderWrapper/Header/HBoxContainer \
            .add_constant_override("separation", PADDING.x)
    $HeaderWrapper/Header/HBoxContainer.rect_min_size = header_size
    $HeaderWrapper/Header/HBoxContainer/RankWrapper.rect_min_size = \
            RANK_ICON_SIZE_DEFAULT * RANK_ICON_SCALE
    $HeaderWrapper/Header/HBoxContainer/RankWrapper/RankAnimator \
            .rect_scale = RANK_ICON_SCALE
    $HeaderWrapper/Header/HBoxContainer/CaretWrapper.rect_min_size = \
            AccordionPanel.CARET_SIZE_DEFAULT * AccordionPanel.CARET_SCALE
    
    var header_style_normal := StyleBoxFlat.new()
    header_style_normal.bg_color = Constants.OPTION_BUTTON_COLOR_NORMAL
    $HeaderWrapper/Header.add_stylebox_override("normal", header_style_normal)
    var header_style_hover := StyleBoxFlat.new()
    header_style_hover.bg_color = Constants.OPTION_BUTTON_COLOR_HOVER
    $HeaderWrapper/Header.add_stylebox_override("hover", header_style_hover)
    var header_style_pressed := StyleBoxFlat.new()
    header_style_pressed.bg_color = Constants.OPTION_BUTTON_COLOR_PRESSED
    $HeaderWrapper/Header \
            .add_stylebox_override("pressed", header_style_pressed)
    
    Utils.set_mouse_filter_recursively( \
            $HeaderWrapper/Header, \
            Control.MOUSE_FILTER_IGNORE)
    
    $AccordionPanel.connect("caret_rotated", self, "_on_caret_rotated")
    $AccordionPanel.connect("toggled", self, "_on_accordion_toggled")

func update() -> void:
    if level_id == "":
        return
    
    # FIXME: REMOVE: for debugging
#    SaveState.set_level_is_unlocked(level_id, true)
    
    var config := LevelConfig.get_level_config(level_id)
    var high_score := SaveState.get_level_high_score(level_id)
    var rank := LevelConfig.get_level_rank( \
            level_id, \
            high_score)
    var high_tier := SaveState.get_level_high_tier(level_id)
    var high_tier_ratio := "%s / %s" % [
        high_tier, \
        config.tiers.size(),
    ]
    var score_for_next_rank_str := _get_score_for_next_rank_str(config, rank)
    var total_plays := SaveState.get_level_total_plays(level_id)
    var is_unlocked := SaveState.get_level_is_unlocked(level_id)
    
    $HeaderWrapper/LockedWrapper.visible = !is_unlocked
    $HeaderWrapper/LockedWrapper.modulate.a = LOCKED_OPACITY
    
    $HeaderWrapper/Header.visible = is_unlocked
    $HeaderWrapper/Header/HBoxContainer/LevelNumber.text = \
            str(config.number) + "."
    $HeaderWrapper/Header/HBoxContainer/LevelName.text = config.name
    $HeaderWrapper/Header/HBoxContainer/RankWrapper/RankAnimator.rank = rank
    
    var list_items := [
        {
            label = "Score for next rank:",
            type = LabeledControlItemType.TEXT,
            text = score_for_next_rank_str,
        },
        {
            label = "High score:",
            type = LabeledControlItemType.TEXT,
            text = str(high_score),
        },
        {
            label = "High tier:",
            type = LabeledControlItemType.TEXT,
            text = high_tier_ratio,
        },
        {
            label = "Total plays:",
            type = LabeledControlItemType.TEXT,
            text = str(total_plays),
        },
    ]
    $AccordionPanel/VBoxContainer/LabeledControlList.items = list_items

func toggle() -> void:
    $AccordionPanel.toggle()

func unlock() -> void:
    $HeaderWrapper/LockedWrapper.visible = true
    $HeaderWrapper/LockedWrapper.modulate.a = LOCKED_OPACITY
    $HeaderWrapper/Header.visible = false
    $HeaderWrapper/Header.modulate.a = 0.0
    $HeaderWrapper/LockedWrapper/LockAnimation.connect( \
            "unlock_finished", \
            self, \
            "_on_unlock_animation_finished")
    
    Time.set_timeout( \
            funcref($HeaderWrapper/LockedWrapper/LockAnimation, "unlock"), \
            LOCK_LOW_PART_DELAY_SEC)
    
    Time.set_timeout( \
            funcref(Audio, "play_sound"), \
            LOCK_LOW_PART_DELAY_SEC, \
            [Sound.LOCK_LOW])
    Time.set_timeout( \
            funcref(Audio, "play_sound"), \
            LOCK_LOW_PART_DELAY_SEC + LOCK_HIGH_PART_DELAY_SEC, \
            [Sound.LOCK_HIGH])

func _on_unlock_animation_finished() -> void:
    $HeaderWrapper/LockedWrapper.visible = true
    $HeaderWrapper/Header.visible = true
    var fade_tween := Tween.new()
    $HeaderWrapper/LockedWrapper.add_child(fade_tween)
    fade_tween.connect( \
            "tween_all_completed", \
            self, \
            "_on_unlock_fade_finished", \
            [fade_tween])
    fade_tween.interpolate_property( \
            $HeaderWrapper/LockedWrapper, \
            "modulate:a", \
            LOCKED_OPACITY, \
            0.0, \
            FADE_TWEEN_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT)
    fade_tween.interpolate_property( \
            $HeaderWrapper/Header, \
            "modulate:a", \
            0.0, \
            1.0, \
            FADE_TWEEN_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT)
    fade_tween.start()

func _on_unlock_fade_finished(fade_tween: Tween) -> void:
    $HeaderWrapper/LockedWrapper.remove_child(fade_tween)
    $HeaderWrapper/LockedWrapper.visible = false
    $HeaderWrapper/Header.visible = true
    toggle()

func _on_header_pressed() -> void:
    Global.give_button_press_feedback()
    toggle()

func _on_PlayButton_pressed():
    Global.give_button_press_feedback(true)
    Nav.open(ScreenType.GAME)
    Nav.screens[ScreenType.GAME].start_level(level_id)

func _on_accordion_toggled() -> void:
    emit_signal("toggled")

func _on_caret_rotated(rotation: float) -> void:
    $HeaderWrapper/Header/HBoxContainer/CaretWrapper/Caret \
            .rect_rotation = rotation

func _set_level_id(value: String) -> void:
    level_id = value
    update()

func _get_level_id() -> String:
    return level_id

func _set_is_open(value: bool) -> void:
    $AccordionPanel.is_open = value
    update()

func _get_is_open() -> bool:
    return $AccordionPanel.is_open

func _get_score_for_next_rank_str( \
        level_config: Dictionary, \
        current_rank: int) -> String:
    match current_rank:
        Rank.BRONZE:
            return str(level_config.rank_thresholds[Rank.SILVER])
        Rank.SILVER:
            return str(level_config.rank_thresholds[Rank.GOLD])
        Rank.GOLD:
            return "-"
        Rank.UNRANKED:
            return "(finish level)"
        _:
            Utils.error()
            return ""
