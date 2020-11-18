extends Screen
class_name LevelSelectScreen

const TYPE := ScreenType.LEVEL_SELECT
const DEFAULT_SELECTED_LEVEL_ID := "1"

const LEVEL_ITEM_PREFIX := "Level "

var selected_level_id := DEFAULT_SELECTED_LEVEL_ID
# Array<String>
var level_items := []

func _init().(TYPE) -> void:
    pass

func _ready() -> void:
    var selector := \
            $CenteredInFullScreenPanel/CenterPanelOuter/CenterPanelInner/VBoxContainer/VBoxContainer/LevelSelector
    
    for id in LevelConfig.LEVELS:
        var item := "%s%s" % [LEVEL_ITEM_PREFIX, id]
        level_items.push_back(item)
        selector.add_item(item)
    
    var default_label := "%s%s" % [LEVEL_ITEM_PREFIX, selected_level_id]
    var default_index := level_items.find(default_label)
    selector.select(default_index)

func _on_LevelSelector_pressed():
    Global.give_button_press_feedback()

func _on_LevelSelector_item_selected(index: int) -> void:
    Global.give_button_press_feedback()
    var level_id: String = \
            level_items[index].substr(LEVEL_ITEM_PREFIX.length())
    selected_level_id = level_id

func _on_StartGameButton_pressed():
    Global.give_button_press_feedback()
    Nav.set_screen_is_open( \
            ScreenType.GAME, \
            true)
    Nav.screens[ScreenType.GAME].start_level(selected_level_id)
