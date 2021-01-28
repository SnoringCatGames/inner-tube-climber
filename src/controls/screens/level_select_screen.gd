tool
extends Screen
class_name LevelSelectScreen

const LEVEL_SELECT_ITEM_RESOURCE_PATH := \
        "res://src/controls/level_select_item.tscn"

const SCROLL_TWEEN_DURATION_SEC := 0.3

const TYPE := ScreenType.LEVEL_SELECT
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true

# Array<LevelSelectItem>
var level_items := []
var expanded_item: LevelSelectItem

func _init().( \
        TYPE, \
        INCLUDES_STANDARD_HIERARCHY, \
        INCLUDES_NAV_BAR, \
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass

func _on_activated() -> void:
    ._on_activated()
    _update()

func _ready() -> void:
    for level_id in LevelConfig.get_level_ids():
        var item: LevelSelectItem = Utils.add_scene( \
                $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer \
                        /CenterContainer/VBoxContainer/LevelSelectItems, \
                LEVEL_SELECT_ITEM_RESOURCE_PATH, \
                true, \
                true)
        level_items.push_back(item)
        item.level_id = level_id
        item.is_open = false
        item.connect("toggled", self, "_on_item_toggled", [item])
        # FIXME
        if false:
            expanded_item = item
    
    if expanded_item != null:
        expanded_item.is_open = true

func _update() -> void:
    for item in level_items:
        item.update()
    var new_unlocked_levels := SaveState.get_new_unlocked_levels()
    if !new_unlocked_levels.empty():
        var last_new_unlocked_level: String = new_unlocked_levels.back()
        var unlocked_item: LevelSelectItem
        for item in level_items:
            if item.is_open:
                item.toggle()
            if item.level_id == last_new_unlocked_level:
                unlocked_item = item
        assert(unlocked_item != null)
        _scroll_to_item_to_unlock(unlocked_item)

func _scroll_to_item_to_unlock(item: LevelSelectItem) -> void:
    var scroll_tween := Tween.new()
    add_child(scroll_tween)
    var scroll_start := scroll_container.get_v_scrollbar().min_value
    var scroll_end := Utils.get_node_vscroll_position(scroll_container, item)
    scroll_tween.interpolate_property( \
            scroll_container, \
            "scroll_vertical", \
            scroll_start, \
            scroll_end, \
            SCROLL_TWEEN_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT)
    scroll_tween.connect( \
            "tween_all_completed", \
            self, \
            "_on_unlock_scroll_finished", \
            [item, scroll_tween])
    scroll_tween.start()

func _on_unlock_scroll_finished( \
        item: LevelSelectItem, \
        scroll_tween: Tween) -> void:
    remove_child(scroll_tween)
    item.unlock()
    SaveState.set_new_unlocked_levels([])

func _get_focused_button() -> ShinyButton:
    return null

func _on_item_toggled(item: LevelSelectItem) -> void:
    if item.is_open:
        if expanded_item != null:
            expanded_item.toggle()
        expanded_item = item
    elif expanded_item == item:
        expanded_item = null
