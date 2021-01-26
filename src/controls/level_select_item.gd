tool
extends Control
class_name LevelSelectItem

# FIXME: ----------------------
# - SaveState
#   - save level state by both ID and version
#   - is_locked
#   - rank
#   - high score
#   - high tier
#   - total number of plays
#   - all scores
#   - all tiers
# - rank
#   - Gold, Silver, Bronze
#   - Create icons
#   - Create level config values
#   - Save values in SaveState
# - total number of plays
# - start button
# - locked indicator
# - High score
# - High tier
# - Score for next rank

signal toggled

const HEADER_HEIGHT := 56.0
const PADDING := Vector2(16.0, 8.0)
const RANK_ICON_SIZE_DEFAULT := RankAnimator.SMALL_SIZE
const RANK_ICON_SCALE := Vector2(1.0, 1.0)

export var level_id := "" setget _set_level_id,_get_level_id
export var is_open: bool setget _set_is_open,_get_is_open

func _ready() -> void:
    _init_children()
    call_deferred("_update")

func _on_activated() -> void:
    ._on_activated()
    _update()

func _process(_delta_sec: float) -> void:
    rect_min_size.y = $AccordionPanel.rect_min_size.y

func _init_children() -> void:
    var header_size := Vector2(rect_size.x, HEADER_HEIGHT)
    
    $LockedWrapper.rect_min_size = header_size
    
    $Header.rect_min_size = header_size
    $Header.connect("pressed", self, "_on_header_pressed")
    $Header/HBoxContainer.add_constant_override("separation", PADDING.x)
    $Header/HBoxContainer.rect_min_size = header_size
    $Header/HBoxContainer/RankWrapper.rect_min_size = \
            RANK_ICON_SIZE_DEFAULT * RANK_ICON_SCALE
    $Header/HBoxContainer/RankWrapper/RankAnimator.rect_scale = RANK_ICON_SCALE
    $Header/HBoxContainer/CaretWrapper.rect_min_size = \
            AccordionPanel.CARET_SIZE_DEFAULT * AccordionPanel.CARET_SCALE
    
    var header_style_normal := StyleBoxFlat.new()
    header_style_normal.bg_color = Constants.OPTION_BUTTON_COLOR_NORMAL
    $Header.add_stylebox_override("normal", header_style_normal)
    var header_style_hover := StyleBoxFlat.new()
    header_style_hover.bg_color = Constants.OPTION_BUTTON_COLOR_HOVER
    $Header.add_stylebox_override("hover", header_style_hover)
    var header_style_pressed := StyleBoxFlat.new()
    header_style_pressed.bg_color = Constants.OPTION_BUTTON_COLOR_PRESSED
    $Header.add_stylebox_override("pressed", header_style_pressed)
    
    Utils.set_mouse_filter_recursively( \
            $Header, \
            Control.MOUSE_FILTER_IGNORE)
    
    $AccordionPanel.connect("caret_rotated", self, "_on_caret_rotated")
    $AccordionPanel.connect("toggled", self, "_on_accordion_toggled")

func _update() -> void:
    if level_id == "":
        return
    
    var config := LevelConfig.get_level_config(level_id)
    var rank := LevelConfig.get_level_rank(level_id)
    
    $LockedWrapper.visible = config.is_locked
    
    $Header.visible = !config.is_locked
    $Header/HBoxContainer/LevelNumber.text = config.id + "."
    $Header/HBoxContainer/LevelName.text = config.name
    $Header/HBoxContainer/RankWrapper/RankAnimator.rank = rank
    
    var list_items := [
        {
            label = "Score for next rank:",
            type = LabeledControlItemType.TEXT,
            text = "foo",
        },
        {
            label = "High score:",
            type = LabeledControlItemType.TEXT,
            text = "bar",
        },
        {
            label = "High tier:",
            type = LabeledControlItemType.TEXT,
            text = "baz",
        },
        {
            label = "Total plays:",
            type = LabeledControlItemType.TEXT,
            text = "qux",
        },
    ]
    $AccordionPanel/VBoxContainer/LabeledControlList.items = list_items

func toggle() -> void:
    $AccordionPanel.toggle()

func unlock() -> void:
    $LockedWrapper/LockAnimation.unlock()
    $LockedWrapper/LockAnimation.connect( \
            "unlock_finished", \
            self, \
            "_on_unlock_finished")

func _on_unlock_finished() -> void:
    $LockedWrapper.visible = false
    $Header.visible = true

func _on_header_pressed() -> void:
    Global.give_button_press_feedback()
    toggle()

func _on_PlayButton_pressed():
    Global.give_button_press_feedback()
    Nav.open(ScreenType.GAME)
    Nav.screens[ScreenType.GAME].start_level(level_id)

func _on_accordion_toggled() -> void:
    emit_signal("toggled")

func _on_caret_rotated(rotation: float) -> void:
    $Header/HBoxContainer/CaretWrapper/Caret.rect_rotation = rotation

func _set_level_id(value: String) -> void:
    level_id = value
    _update()

func _get_level_id() -> String:
    return level_id

func _set_is_open(value: bool) -> void:
    $AccordionPanel.is_open = value
    _update()

func _get_is_open() -> bool:
    return $AccordionPanel.is_open
