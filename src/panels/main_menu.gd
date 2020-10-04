class_name MainMenu
extends Panel

signal on_start_game_pressed

const BUTTON_PRESS_SFX_STREAM := preload("res://assets/sfx/menu_select.wav")

const TIER_ITEMS := [
    "Level 0",
    "Level 1",
    "Level 2",
    "Level 3",
    "Level 4",
    "Level 5",
    "Level 6",
    "Level 7",
]

const IS_EASY_MODE_ON_BY_DEFAULT := true
const DEFAULT_SELECTED_TIER_INDEX := 0

var button_press_sfx_player: AudioStreamPlayer

var selected_tier_index := DEFAULT_SELECTED_TIER_INDEX

func _init() -> void:
    button_press_sfx_player = AudioStreamPlayer.new()
    button_press_sfx_player.stream = BUTTON_PRESS_SFX_STREAM
    button_press_sfx_player.volume_db = -6.0
    add_child(button_press_sfx_player)

func _ready() -> void:
    $HBoxContainer/VBoxContainer/VBoxContainer/VBoxContainer2/EasyModeCheckbox.pressed = \
            IS_EASY_MODE_ON_BY_DEFAULT
    Global.current_level.is_stuck_in_a_retry_loop = IS_EASY_MODE_ON_BY_DEFAULT
    
    var selector := \
            $HBoxContainer/VBoxContainer/VBoxContainer/VBoxContainer2/TierSelector
    for item in TIER_ITEMS:
        selector.add_item(item)

func _on_StartGameButton_pressed() -> void:
    button_press_sfx_player.play()
    emit_signal("on_start_game_pressed")

func _on_CreditsButton_pressed() -> void:
    button_press_sfx_player.play()
    $CreditsPanel.visible = true

func _on_EasyModeCheckbox_toggled(button_pressed: bool) -> void:
    button_press_sfx_player.play()
    Global.current_level.is_stuck_in_a_retry_loop = button_pressed

func _on_TierSelector_item_selected(index: int) -> void:
    selected_tier_index = index

func set_high_score(high_score: int) -> void:
    $HBoxContainer/VBoxContainer/CenterContainer/HighScoreLabel.text = \
            "Your high score:    %s points" % high_score
