extends Node

const LOADING_SCREEN_PATH := "res://src/screens/loading_screen.tscn"
const MAIN_MENU_SCREEN_PATH := "res://src/screens/main_menu_screen.tscn"
const GAME_SCREEN_PATH := "res://src/screens/game_screen.tscn"
const SETTINGS_SCREEN_PATH := "res://src/screens/settings_screen.tscn"
const PAUSE_SCREEN_PATH := "res://src/screens/pause_screen.tscn"
const THIRD_PARTY_LICENSES_SCREEN_PATH := \
        "res://src/screens/third_party_licenses_screen.tscn"
const CREDITS_SCREEN_PATH := "res://src/screens/credits_screen.tscn"
const LEVEL_SELECT_SCREEN_PATH := "res://src/screens/level_select_screen.tscn"

# Dictionary<ScreenType, Screen>
var screens := {}
# Array<Screen>
var active_screen_stack := []

var loading_screen: Node
var is_loading_screen_shown := true

func create_screens() -> void:
    screens[ScreenType.MAIN_MENU] = Utils.add_scene( \
            Global.canvas_layers.menu_screen_layer, \
            MAIN_MENU_SCREEN_PATH, \
            true, \
            false)
    screens[ScreenType.CREDITS] = Utils.add_scene( \
            Global.canvas_layers.menu_screen_layer, \
            CREDITS_SCREEN_PATH, \
            true, \
            false)
    screens[ScreenType.THIRD_PARTY_LICENSES] = Utils.add_scene( \
            Global.canvas_layers.menu_screen_layer, \
            THIRD_PARTY_LICENSES_SCREEN_PATH, \
            true, \
            false)
    screens[ScreenType.SETTINGS] = Utils.add_scene( \
            Global.canvas_layers.menu_screen_layer, \
            SETTINGS_SCREEN_PATH, \
            true, \
            false)
    screens[ScreenType.PAUSE] = Utils.add_scene( \
            Global.canvas_layers.menu_screen_layer, \
            PAUSE_SCREEN_PATH, \
            true, \
            false)
    screens[ScreenType.GAME] = Utils.add_scene( \
            Global.canvas_layers.game_screen_layer, \
            GAME_SCREEN_PATH, \
            true, \
            false)
    screens[ScreenType.LEVEL_SELECT] = Utils.add_scene( \
            Global.canvas_layers.menu_screen_layer, \
            LEVEL_SELECT_SCREEN_PATH, \
            true, \
            false)

func set_screen_is_open( \
        screen_type: int, \
        is_open: bool) -> void:
    var screen: Screen = screens[screen_type]
    var is_paused := screen_type != ScreenType.GAME
    
    if is_open:
        if !active_screen_stack.has(screen):
            if !active_screen_stack.empty():
                active_screen_stack.back().visible = false
            screen.visible = true
            active_screen_stack.push_back(screen)
        else:
            # Do nothing. Screen is already active.
            pass
    else:
        var index := active_screen_stack.find(screen)
        if index >= 0:
            while index <= active_screen_stack.size():
                active_screen_stack.pop_back().visible = false
        active_screen_stack.back().visible = true
    
    get_tree().paused = is_paused

func close_current_screen() -> void:
    assert(!active_screen_stack.empty())
    var current_screen: Screen = active_screen_stack.pop_back()
    current_screen.visible = false
    if !active_screen_stack.empty():
        active_screen_stack.back().visible = true

func start_loading() -> void:
    if OS.get_name() == "HTML5":
        # For HTML, don't use the Godot loading screen, and instead use an
        # HTML screen, which will be more consistent with the other screens
        # shown before.
        JavaScript.eval("window.onLoadingScreenReady()")
    else:
        # For non-HTML platforms, show a loading screen in Godot.
        loading_screen = Utils.add_scene( \
                Global.canvas_layers.menu_screen_layer, \
                LOADING_SCREEN_PATH)

func finish_loading() -> void:
    is_loading_screen_shown = false
    
    # Hide the loading screen.
    if loading_screen != null:
        Global.canvas_layers.menu_screen_layer.remove_child(loading_screen)
        loading_screen.queue_free()
        loading_screen = null
    
    set_screen_is_open( \
            ScreenType.MAIN_MENU, \
            true)
    
    if OS.get_name() == "HTML5":
        JavaScript.eval("window.onLevelReady()")
    
    # Start playing the default music for the menu screen.
    Audio.cross_fade_music(Audio.MAIN_MENU_MUSIC_PLAYER_INDEX)
