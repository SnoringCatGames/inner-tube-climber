extends Node
class_name Main

###############################################################################
### MAIN TODO LIST: ###
# 
# - Fix jerky screen displacement at start (when menu replaces loading screen?).
# - New tile art:
#   - Fix issue with tiles at top/bottom of adjacent tiers not matching up /
#     binding.
#     - Maybe the fix is to instead remove the top row, and most of the bottom
#       (except the middle platforms and the two surrounding wall tiles), and
#       then create a couple possible filler scenes that are just the relevant
#       between rows for whatever combination of previous/next tier types we're
#       facing.
#     - Make the Tier scene a `tool`, and expose a flag to the editor for
#       configuring whether the given Tier is open or walled.
#     - Actually, make this be an enum instead of a flag, then we can also
#       support the upcoming feature of "HORIZONTAL_PANNING".
# - Change score to accumulate between deaths.
#   - Maybe count current elevation separately.
#   - Then can make score more complicated, subracting deaths, including a
#     multiplier for speed, etc.
#     - Maybe, we should do something else for score...:
#       - We want to allow some number of resets/falls.
#       - We want to keep the scroll accelerating, but maybe slow a little on
#         each fall.
#       - Maybe it's easy, just give X (3?) lives per level attempt.
#         - Then can still slow scroll a bit on each death, and we don't need
#           to worry too much about how to adjust score, and/or even force an
#           end condnition.
#       - But then also have a hard-mode with one life, and faster initial
#         speed, but slower acceleration.
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
#   - Theme-wise, we can eventually make the player escape the crevasse and
#     start climbing up the mountain.
#   - We can show trees and mountain range in the background.
#   - Idk if there's something clever we can do to make the inner-tubing
#     continue to make sense at this point though... why would they care to do
#     more than escape the crevasse?
#   - And then, what is the end goal? Is there something they get at the top of
#     the mountain? Or just the beautiful view?
#   - How do we then make it loop?
#     - Maybe, show a cut-scene after the final mountain-ascent tier, once
#       they've reached the summit.
#     - Show a flag, show a beautiful sun-rise, show them stop and finally free
#       themselves from their inner tube (maybe with a tool or with some help?),
#       then show them start tubing down the mountain again, and repeat the
#       intro animation in order to loop back to the start level.
# - Make the wall-bounce-vertical-boost more consistent/predictable; don't want
#   it to be better to bounce near bottom of jump instead of top.
# - Add a delay after falling before restarting.
# - Make a level te emphasize the slipperiness of ice (mostly snow, but fail on
#   ice  near the top, must jump to bounce off wall).
# - Make a level to emphasize dynamic jump height.
# - Mobile control idea: touch either corner to move sideways, swipe slightly
#   up on either to jump.
# 
# Long-term planning:
# - Maybe have a set sequence of tiers per-day? Per week? Per month?
#   - Randomly shuffle?
#   - Pre-generate for the whole year, at least.
# - Or have a set of pre-made levels, with their own tier sequences, each
#   showing the ascent art transition and summit animation.
#   - Could show a different flag color for each level.
#   - Anything else interesting to differentiate, art-wise?
#   - Clearly, difficulty of levels should change.
# - Show a leaderboard for each level, and also for the current special/rotating
#   level.
#   - Leaderboard should show a couple things:
#     - Farthest climbed without dying.
#       - Or score?
#     - Fastest ascent through one cycle of the level.
#   - Show username, and their score/speed.
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
