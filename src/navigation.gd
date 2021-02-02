extends Node

const SPLASH_SCREEN_PATH := \
        "res://src/controls/screens/splash_screen.tscn"
const MAIN_MENU_SCREEN_PATH := \
        "res://src/controls/screens/main_menu_screen.tscn"
const GAME_SCREEN_PATH := \
        "res://src/controls/screens/game_screen.tscn"
const SETTINGS_SCREEN_PATH := \
        "res://src/controls/screens/settings_screen.tscn"
const PAUSE_SCREEN_PATH := \
        "res://src/controls/screens/pause_screen.tscn"
const THIRD_PARTY_LICENSES_SCREEN_PATH := \
        "res://src/controls/screens/third_party_licenses_screen.tscn"
const CREDITS_SCREEN_PATH := \
        "res://src/controls/screens/credits_screen.tscn"
const LEVEL_SELECT_SCREEN_PATH := \
        "res://src/controls/screens/level_select_screen.tscn"
const DATA_AGREEMENT_SCREEN_PATH := \
        "res://src/controls/screens/data_agreement_screen.tscn"
const RATE_APP_SCREEN_PATH := \
        "res://src/controls/screens/rate_app_screen.tscn"
const GAME_OVER_SCREEN_PATH := \
        "res://src/controls/screens/game_over_screen.tscn"
const CONFIRM_DATA_DELETION_SCREEN_PATH := \
        "res://src/controls/screens/confirm_data_deletion_screen.tscn"
const FADE_TRANSITION_PATH := \
        "res://src/controls/screens/fade_transition.tscn"

const SCREEN_SLIDE_DURATION_SEC := 0.3
const SCREEN_FADE_DURATION_SEC := 1.0
const SESSION_END_TIMEOUT_SEC := 2.0

# Dictionary<ScreenType, Screen>
var screens := {}
# Array<Screen>
var active_screen_stack := []

var fade_transition: FadeTransition

func _ready() -> void:
    fade_transition.connect( \
            "fade_complete", \
            self, \
            "_on_fade_complete")
    get_tree().set_auto_accept_quit(false)
    Analytics.connect( \
            "session_end", \
            self, \
            "_on_session_end")
    Analytics.start_session()

func _notification(notification: int) -> void:
    if notification == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
        # Handle the Android back button to navigate within the app instead of
        # quitting the app.
        if get_active_screen_type() == ScreenType.MAIN_MENU:
            Analytics.end_session()
            Time.set_timeout( \
                    funcref(self, "_on_session_end"), \
                    SESSION_END_TIMEOUT_SEC)
        else:
            call_deferred("close_current_screen")
    elif notification == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        Analytics.end_session()
        Time.set_timeout( \
                funcref(self, "_on_session_end"), \
                SESSION_END_TIMEOUT_SEC)

func _on_session_end() -> void:
    get_tree().quit()

func create_screens() -> void:
    screens[ScreenType.SPLASH] = Utils.add_scene( \
            Global.canvas_layers.menu_screen_layer, \
            SPLASH_SCREEN_PATH, \
            true, \
            false)
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
    screens[ScreenType.DATA_AGREEMENT] = Utils.add_scene( \
            Global.canvas_layers.menu_screen_layer, \
            DATA_AGREEMENT_SCREEN_PATH, \
            true, \
            false)
    screens[ScreenType.RATE_APP] = Utils.add_scene( \
            Global.canvas_layers.menu_screen_layer, \
            RATE_APP_SCREEN_PATH, \
            true, \
            false)
    screens[ScreenType.GAME_OVER] = Utils.add_scene( \
            Global.canvas_layers.menu_screen_layer, \
            GAME_OVER_SCREEN_PATH, \
            true, \
            false)
    screens[ScreenType.CONFIRM_DATA_DELETION] = Utils.add_scene( \
            Global.canvas_layers.menu_screen_layer, \
            CONFIRM_DATA_DELETION_SCREEN_PATH, \
            true, \
            false)
    fade_transition = Utils.add_scene( \
            Global.canvas_layers.top_layer, \
            FADE_TRANSITION_PATH, \
            true, \
            false)
    fade_transition.duration = SCREEN_FADE_DURATION_SEC

func open(screen_type: int) -> void:
    _set_screen_is_open(screen_type, true)

func close_current_screen() -> void:
    assert(!active_screen_stack.empty())
    _set_screen_is_open( \
            get_active_screen_type(), \
            false)

func get_active_screen() -> Screen:
    return active_screen_stack.back()

func get_active_screen_type() -> int:
    return get_active_screen().type

func _set_screen_is_open( \
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
    
    var is_paused := \
            next_screen != null and \
            next_screen.type != ScreenType.GAME
    var is_first_screen := is_open and active_screen_stack.empty()
    
    var next_screen_was_already_shown := false
    if is_open:
        if !active_screen_stack.has(next_screen):
            active_screen_stack.push_back(next_screen)
        else:
            next_screen_was_already_shown = true
    
    # Remove all (potential) following screens from the stack.
    var index := active_screen_stack.find(next_screen)
    while index + 1 < active_screen_stack.size():
        var removed_screen: Screen = active_screen_stack.back()
        active_screen_stack.pop_back()
        removed_screen.visible = false
    
    get_tree().paused = is_paused
    
    if previous_screen != null:
        previous_screen.visible = true
        previous_screen.z_index = \
                -100 + active_screen_stack.find(previous_screen) if \
                active_screen_stack.has(previous_screen) else \
                -100 + active_screen_stack.size()
    if next_screen != null:
        next_screen.visible = true
        next_screen.z_index = -100 + active_screen_stack.find(next_screen)
    
    if !is_first_screen:
        var start_position: Vector2
        var end_position: Vector2
        var tween_screen: Screen
        if screen_type == ScreenType.GAME:
            start_position = Vector2.ZERO
            end_position = Vector2( \
                    -get_viewport().size.x, \
                    0.0)
            tween_screen = previous_screen
        elif next_screen_was_already_shown:
            start_position = Vector2( \
                    get_viewport().size.x, \
                    0.0)
            end_position = Vector2.ZERO
            tween_screen = next_screen
            var swap_z_index := next_screen.z_index
            next_screen.z_index = previous_screen.z_index
            previous_screen.z_index = swap_z_index
        elif is_open:
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
        
        var slide_duration := SCREEN_SLIDE_DURATION_SEC
        var slide_delay := 0.0
        if screen_type == ScreenType.GAME or \
                screen_type == ScreenType.GAME_OVER:
            fade_transition.visible = true
            fade_transition.fade()
            slide_duration = SCREEN_SLIDE_DURATION_SEC / 2.0
            slide_delay = (SCREEN_FADE_DURATION_SEC - slide_duration) / 2.0
        
        var screen_slide_tween := Tween.new()
        add_child(screen_slide_tween)
        tween_screen.position = start_position
        screen_slide_tween.interpolate_property( \
                tween_screen, \
                "position", \
                start_position, \
                end_position, \
                SCREEN_SLIDE_DURATION_SEC, \
                Tween.TRANS_QUAD, \
                Tween.EASE_IN_OUT, \
                slide_delay)
        screen_slide_tween.start()
        screen_slide_tween.connect( \
                "tween_completed", \
                self, \
                "_on_screen_slide_completed", \
                [ \
                        previous_screen, \
                        next_screen, \
                        screen_slide_tween, \
                ])
    
    if next_screen != null:
        next_screen._on_activated()
        # If opening a new screen, auto-scroll to the top. Otherwise, if
        # navigating back to a previous screen, maintain the scroll position,
        # so the user can remember where they were.
        if is_open:
            next_screen._scroll_to_top()
    
    if next_screen != null:
        Analytics.screen(ScreenType.get_type_string(next_screen.type))

func _on_screen_slide_completed( \
        _object: Object, \
        _key: NodePath, \
        previous_screen: Screen, \
        next_screen: Screen, \
        tween: Tween) -> void:
    remove_child(tween)
    tween.queue_free()
    
    if previous_screen != null:
        previous_screen.visible = false
        previous_screen.position = Vector2.ZERO
        previous_screen._on_deactivated()
    if next_screen != null:
        next_screen.visible = true
        next_screen.position = Vector2.ZERO

func _on_fade_complete() -> void:
    if !fade_transition.is_transitioning:
        fade_transition.visible = false
