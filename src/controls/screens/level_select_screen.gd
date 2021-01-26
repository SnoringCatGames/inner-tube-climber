tool
extends Screen
class_name LevelSelectScreen

const LEVEL_SELECT_ITEM_RESOURCE_PATH := \
        "res://src/controls/level_select_item.tscn"

# FIXME:
# - Determine which level to suggest (or none).
#   - Auto expand.
#   - (Don't auto-scroll separately, since that'll happen automatically when expanding?)
#   - Return it's button as the shiny button to focus on.

const TYPE := ScreenType.LEVEL_SELECT
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true

# Array<String>
var level_items := []
var expanded_item: LevelSelectItem

func _init().( \
        TYPE, \
        INCLUDES_STANDARD_HIERARCHY, \
        INCLUDES_NAV_BAR, \
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass

func _ready() -> void:
    for level_id in LevelConfig.get_level_ids():
        var item: LevelSelectItem = Utils.add_scene( \
                $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer \
                        /CenterContainer/VBoxContainer/LevelSelectItems, \
                LEVEL_SELECT_ITEM_RESOURCE_PATH, \
                true, \
                true)
        item.level_id = level_id
        item.is_open = false
        item.connect("toggled", self, "_on_item_toggled", [item])
        # FIXME
        if false:
            expanded_item = item
    
    if expanded_item != null:
        expanded_item.is_open = true

func _get_focused_button() -> ShinyButton:
    return null

func _on_item_toggled(item: LevelSelectItem) -> void:
    if item.is_open:
        if expanded_item != null:
            expanded_item.toggle()
        expanded_item = item
    elif expanded_item == item:
        expanded_item = null
