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
var _scroll_target: LevelSelectItem

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

func _update() -> void:
    for item in level_items:
        item.update()
    call_deferred("_deferred_update")

func _deferred_update() -> void:
    var previous_open_item: LevelSelectItem
    for item in level_items:
        if item.is_open:
            previous_open_item = item
    
    var new_unlocked_levels := SaveState.get_new_unlocked_levels()
    
    if new_unlocked_levels.empty():
        if previous_open_item == null:
            var suggested_level_id: String = \
                    LevelConfig.get_suggested_next_level()
            var item_to_open: LevelSelectItem
            for item in level_items:
                if item.level_id == suggested_level_id:
                    item_to_open = item
            assert(item_to_open != null)
            item_to_open.toggle()
    else:
        var last_new_unlocked_level: String = new_unlocked_levels.back()
        var unlocked_item: LevelSelectItem
        for item in level_items:
            if item.level_id == last_new_unlocked_level:
                unlocked_item = item
        assert(unlocked_item != null)
        
        var is_closing_accordion_first := previous_open_item != null
        if is_closing_accordion_first:
            previous_open_item.toggle()
        
        _scroll_to_item_to_unlock( \
                unlocked_item, \
                is_closing_accordion_first)

func _scroll_to_item_to_unlock( \
        item: LevelSelectItem, \
        include_delay_for_accordion_scroll: bool) -> void:
    var scroll_tween := Tween.new()
    add_child(scroll_tween)
    _scroll_target = item
    var delay := \
            AccordionPanel.SCROLL_TWEEN_DURATION_SEC if \
            include_delay_for_accordion_scroll else \
            0.0
    scroll_tween.interpolate_method( \
            self, \
            "_interpolate_scroll", \
            0.0, \
            1.0, \
            SCROLL_TWEEN_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT, \
            delay)
    scroll_tween.connect( \
            "tween_all_completed", \
            self, \
            "_on_unlock_scroll_finished", \
            [item, scroll_tween])
    scroll_tween.start()

func _interpolate_scroll(scroll_ratio: float) -> void:
    var scroll_start := scroll_container.get_v_scrollbar().min_value
    var scroll_end := \
            Utils.get_node_vscroll_position(scroll_container, _scroll_target)
    scroll_container.scroll_vertical = lerp( \
            scroll_start, \
            scroll_end, \
            scroll_ratio)

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
    
    _give_button_focus(item.get_button())
