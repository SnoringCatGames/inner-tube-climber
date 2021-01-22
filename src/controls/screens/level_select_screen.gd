extends Screen
class_name LevelSelectScreen

const TYPE := ScreenType.LEVEL_SELECT
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true
const DEFAULT_SELECTED_LEVEL_ID := "1"

const LEVEL_ITEM_PREFIX := "Level "

var selected_level_id := DEFAULT_SELECTED_LEVEL_ID
# Array<String>
var level_items := []

func _init().( \
        TYPE, \
        INCLUDES_STANDARD_HIERARCHY, \
        INCLUDES_NAV_BAR, \
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass

func _ready() -> void:
    var selector := $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/VBoxContainer/ \
            LevelSelector
    
    for id in LevelConfig.get_level_ids():
        var item := "%s%s" % [LEVEL_ITEM_PREFIX, id]
        level_items.push_back(item)
        selector.add_item(item)
    
    var default_label := "%s%s" % [LEVEL_ITEM_PREFIX, selected_level_id]
    var default_index := level_items.find(default_label)
    selector.select(default_index)

func _get_focused_button() -> ShinyButton:
    return $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer/StartGameButton as \
            ShinyButton

func _on_LevelSelector_pressed():
    Global.give_button_press_feedback()

func _on_LevelSelector_item_selected(index: int) -> void:
    Global.give_button_press_feedback()
    var level_id: String = \
            level_items[index].substr(LEVEL_ITEM_PREFIX.length())
    selected_level_id = level_id

func _on_StartGameButton_pressed():
    Global.give_button_press_feedback(true)
    Nav.open(ScreenType.GAME)
    Nav.screens[ScreenType.GAME].start_level(selected_level_id)
