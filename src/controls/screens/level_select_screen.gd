extends Screen
class_name LevelSelectScreen

const TYPE := ScreenType.LEVEL_SELECT
const TIER_ITEMS := [
    "Tier 0",
    "Tier 1",
    "Tier 2",
    "Tier 3",
    "Tier 4",
    "Tier 5",
    "Tier 6",
    "Tier 7",
]
const DEFAULT_SELECTED_TIER_INDEX := 0

var selected_tier_index := DEFAULT_SELECTED_TIER_INDEX

func _init().(TYPE) -> void:
    pass

func _ready() -> void:
    var selector := \
            $CenteredInFullScreenPanel/VBoxContainer/VBoxContainer/TierSelector
    for item in TIER_ITEMS:
        selector.add_item(item)

func _on_TierSelector_pressed():
    Audio.button_press_sfx_player.play()

func _on_TierSelector_item_selected(index: int) -> void:
    Audio.button_press_sfx_player.play()
    selected_tier_index = index

func _on_StartGameButton_pressed():
    Audio.button_press_sfx_player.play()
    Nav.set_screen_is_open( \
            ScreenType.GAME, \
            true)
    Nav.screens[ScreenType.GAME].start_level(selected_tier_index)
