extends Node

const MAIN_MENU_SCREEN_PATH := \
        "res://src/controls/screens/main_menu_screen.tscn"
const GAME_SCREEN_PATH := "res://src/controls/screens/game_screen.tscn"
const SETTINGS_SCREEN_PATH := "res://src/controls/screens/settings_screen.tscn"
const PAUSE_SCREEN_PATH := "res://src/controls/screens/pause_screen.tscn"
const THIRD_PARTY_LICENSES_SCREEN_PATH := \
        "res://src/controls/screens/third_party_licenses_screen.tscn"
const CREDITS_SCREEN_PATH := "res://src/controls/screens/credits_screen.tscn"
const LEVEL_SELECT_SCREEN_PATH := \
        "res://src/controls/screens/level_select_screen.tscn"

const SCREEN_SLIDE_DURATION_SEC := 0.3

# Dictionary<ScreenType, Screen>
var screens := {}
# Array<Screen>
var active_screen_stack := []

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
    var next_screen: Screen
    var previous_screen: Screen
    if is_open:
        next_screen = screens[screen_type]
        previous_screen = \
                active_screen_stack.back() if \
                !active_screen_stack.empty() else \
                null
    else:
        previous_screen = screens[screen_type]
        var index := active_screen_stack.find(previous_screen)
        assert(index >= 0)
        next_screen = \
                active_screen_stack[index - 1] if \
                index > 0 else \
                null
    
    var is_paused := screen_type != ScreenType.GAME
    var is_first_screen := is_open and active_screen_stack.empty()
    
    if is_open:
        if !active_screen_stack.has(next_screen):
            active_screen_stack.push_back(next_screen)
            next_screen.z_index = active_screen_stack.size()
        else:
            # Do nothing. Screen is already active.
            pass
    else:
        var index := active_screen_stack.find(next_screen)
        while index + 1 < active_screen_stack.size():
            var removed_screen: Screen = active_screen_stack.back()
            active_screen_stack.pop_back()
            removed_screen.visible = false
    
    get_tree().paused = is_paused
    
    if previous_screen != null:
        previous_screen.visible = true
    if next_screen != null:
        next_screen.visible = true
    
    if !is_first_screen:
        var start_position: Vector2
        var end_position: Vector2
        var tween_screen: Screen
        if is_open:
            start_position = Vector2( \
                    get_viewport().size.x, \
                    0.0)
            end_position = Vector2.ZERO
            tween_screen = next_screen
        else:
            start_position = Vector2.ZERO
            end_position = Vector2( \
                    get_viewport().size.x, \
                    0.0)
            tween_screen = previous_screen
        var screen_slide_tween := Tween.new()
        add_child(screen_slide_tween)
        screen_slide_tween.interpolate_property( \
                tween_screen, \
                "position", \
                start_position, \
                end_position, \
                SCREEN_SLIDE_DURATION_SEC, \
                Tween.TRANS_QUAD, \
                Tween.EASE_IN_OUT)
        screen_slide_tween.start()
        screen_slide_tween.connect( \
                "tween_completed", \
                self, \
                "_on_screen_slide_completed", \
                [previous_screen, next_screen, screen_slide_tween])

func _on_screen_slide_completed( \
        object: Object, \
        key: NodePath, \
        previous_screen: Screen, \
        next_screen: Screen, \
        tween: Tween) -> void:
    remove_child(tween)
    tween.queue_free()
    
    if previous_screen != null:
        previous_screen.visible = false
        previous_screen.position = Vector2.ZERO
    if next_screen != null:
        next_screen.visible = true
        next_screen.position = Vector2.ZERO

func close_current_screen() -> void:
    assert(!active_screen_stack.empty())
    set_screen_is_open( \
            active_screen_stack.back().type, \
            false)
