extends Node
class_name Main

###############################################################################
### MAIN TODO LIST: ###
# 
# - New autotiles:
#   - Check friction.
#   - Add under-snow shadow to wall tiles.
#   - Create alternative art for a couple tiles: plain wall r/l; plain floor,
#     plain center.
#   - Create ice-wall tiles.
#   - Fix issue with tiles at top/bottom of adjacent tiers not matching up /
#     binding.
# - Change score to accumulate between deaths.
#   - Maybe count current elevation separately.
#   - Then can make score more complicated, subracting deaths, including a
#     multiplier for speed, etc.
# - Fix scroll speed bug.
#   - Also, maybe have speed decrease after each death.
# - Make scroll speed configurable from the main menu.
# - Configurable frame rate/difficulty from main menu.
# - Add intro animation.
# - Add a pause feature.
#   - In the pause menu, allow the player to quit back to the main menu.
#   - Auto-save progress through each tier to local storage, so the user can
#     resume there on next load?
# - Possible to add levels with lots of sideways movement and camera panning.
#   Probably conditionally lock camera horizontal pan.
# - Make the wall-bounce-vertical-boost more consistent/predictable; don't want
#   it to be better to bounce near bottom of jump instead of top.
# - Add a delay after falling before restarting.
# - Make a level te emphasize the slipperiness of ice (mostly snow, but fail on
#   ice  near the top, must jump to bounce off wall).
# - Make a level to emphasize dynamic jump height.
# - Mobile control idea: touch either corner to move sideways, swipe slightly
#   up on either to jump.
# 
# [30]- Add ability to unlock the bounce jump and the double jump.
#   - Add a flag to tier configs that states whether that tier needs/unlocks
#     it.
#   - Then, just remember in level whether any tier yet has unlocked it.
#   - When a new tier arrives that unloks it, show the key indicator for using
#     it.
#   [30]- Create new tiers to take advantage of these.
# >- Take screenshot?
# [2hr]- Add more intro animations.
# >- Take screenshot?
# - Add an unlock for face-plant-bounce-off-tube-higher-jump after a certain
#   tier.
# - Add an unlock for double jump after a certain tier.
# >- Take screenshot?
# - Add dies irae as game-over/you-lose sound?
# - Balance volumes of sfx and music.
# - Create alternate art for foreground and background for different tiers, in
#   order to add more variety.
# - Increase music playback speed when camera pan speed increases.
# - Polish tilemap tile choices, since autotile isn't working.
# - Fix localStorage usage for high score.
# - Add shading to the tuber player animations.
# - Add an animation to shake the screen on game over.
# 
###############################################################################

const MAIN_MENU_PATH := "res://src/panels/main_menu.tscn"
const LOADING_SCREEN_PATH := "res://src/panels/loading_screen.tscn"
const STARTING_LEVEL_RESOURCE_PATH := "res://src/level/level.tscn"

var loading_screen: Node
var camera_controller: CameraController
var canvas_layers: CanvasLayers
var main_menu: MainMenu
var level: Level
var is_loading_screen_shown := true
var high_score: int = 0

func _enter_tree() -> void:
    camera_controller = CameraController.new()
    add_child(camera_controller)
    
    canvas_layers = CanvasLayers.new()
    add_child(canvas_layers)
    
    if OS.get_name() == "HTML5":
        # For HTML, don't use the Godot loading screen, and instead use an
        # HTML screen, which will be more consistent with the other screens
        # shown before.
        JavaScript.eval("window.onLoadingScreenReady()")
        high_score = JavaScript.eval("window.getHighScore()")
    else:
        # For non-HTML platforms, show a loading screen in Godot.
        loading_screen = Utils.add_scene( \
                canvas_layers.screen_layer, \
                LOADING_SCREEN_PATH)

func _process(delta_sec: float) -> void:
    if level == null and \
            Time.elapsed_play_time_sec > 0.25:
        # Start loading the level.
        level = Utils.add_scene( \
                self, \
                STARTING_LEVEL_RESOURCE_PATH, \
                true, \
                false)
        # Start loading the level.
        main_menu = Utils.add_scene( \
                canvas_layers.screen_layer, \
                MAIN_MENU_PATH, \
                true, \
                false)
    
    elif is_loading_screen_shown and \
            Global.is_level_ready and \
            Time.elapsed_play_time_sec > 0.5:
        is_loading_screen_shown = false
        
        # Hide the loading screen.
        if loading_screen != null:
            canvas_layers.screen_layer.remove_child(loading_screen)
            loading_screen.queue_free()
            loading_screen = null
        
        main_menu.set_high_score(high_score)
        main_menu.visible = true
        
        Global.canvas_layers.on_level_ready()
        
        if OS.get_name() == "HTML5":
            JavaScript.eval("window.onLevelReady()")
        
        level.connect( \
                "back_to_menu", \
                self, \
                "_stop_game")
        level.connect( \
                "game_over", \
                self, \
                "_record_high_score")
        main_menu.connect( \
                "on_start_game_pressed", \
                self, \
                "_start_game")

func _start_game() -> void:
    level.start(main_menu.selected_tier_index)
    main_menu.visible = false

func _stop_game() -> void:
    level.stop()
    main_menu.visible = true

func _record_high_score(score: int) -> void:
    if score > high_score:
        high_score = score
        main_menu.set_high_score(high_score)
        if OS.get_name() == "HTML5":
            JavaScript.eval("window.setHighScore(%d)" % high_score)
