extends Node
class_name Main

###############################################################################
### MAIN TODO LIST: ###
# 
# >>- LEFT OFF HERE: Implementing action/gesture annotator:
#     - Then implement pulses.
#     - Then clean up logic into re-usable helpers.
#       - Create 2 sub-classes with their own process/update/draw/tween logic
#         to handle trigger dots and pulse dots (and probably one for the
#         overall gesture).
#     - Then implement v2 annotator.
#     - Add logic to render the shapes for the animations, rather than just
#       plain circles.
# 
# - Render animated pulsing press position phantom circle to help indicate
#   gestures.
#   - Also render recent positions?
#   - Maybe this is easiest to do as just a sequence of independent debounced
#     positions, that each shows a circle with a sharp/opaque/expand-in with a
#     slow/trasparent/shrink-out.
# 
# - v1 input: test/adjust how gestures work when they cross the mid line.
# 
# - Fix GameScreen stretching and centering on mobile display.
# - _Do_ emulate mouse events with touches, so that menu Controls still work.
# 
# - Add pixel art for the control display pads.
#   - Have the pads consume the entire horizontal width.
#   - Have a clean border down the middle.
#   - Have a gradient to transparent at the top, to help indicate that the user
#     can press anywhere vertically.
#   - Show pads initially as slightly transparent.
#   - Then, after first press + a couple seconds, fade pads to much more
#     transparent.
# 
# - Test exporting to iPhone.
#   - Get dev account for iPhone.
#   - Test touchiness / usability of both mobile control types.
#   - Test dimensions of annotations and gestures; should match precise inch
#     values by using ppi-table calculations and screen-scale calculations.
#     - Print the given OS.get_model_name() value, so I can verify that my
#       table structure should work.
#   - Test haptic feedback.
# 
# - Also update all other screens/panels to dynamically adjust their dimensions
#   as well.
# - Update CanvasLayers to support some layers rendering within game area, and
#   some within entire viewport.
# 
# - Fix easing curve on bounce for main menu animation.
# 
# - Refactor level:
#   - To not have a scene, only a script.
#   - To support many different levels, each with different tier collections.
# 
# - Remove Level.is_game_paused and use Global.pause instead.
#   - Read Godot docs. Will need to whitelist Nodes to continue processing
#     during pause.
# 
# - Add a main-menu settings sub-menu:
#   - Toggle visibility of mobile control display pads.
#   - Toggle haptice feedback.
#   - Have settings persist to local storage.
# 
# - Add-back ability to collide with tier gaps:
#   - The problem is that collisions get weird with tier-gap-walled-to-open.
#   - Will need to check many more alternate TileMaps in surface contact update.
# 
# - When resetting tier after a fall (or, actually, even just starting any
#   non-zero tier), set initial camera pan to be lower down.
#   - And maybe also only start scroll after first input.
# 
# - Add support for logging stats over the network to a backend.
#   - Do I need to get user permissions for that?
#     - Or is it sufficient to post a EULA?
#   - Things to log:
#    Utils.get_screen_ppi(),
#    Utils.get_viewport_ppi(),
#    OS.get_screen_dpi(),
#    IosResolutions.get_screen_ppi(),
#    get_viewport().size.x,
#    get_viewport().size.y,
#    OS.get_screen_scale(),
#    OS.get_screen_size(),
#    OS.window_size,
#    OS.get_real_window_size(),
#    OS.get_name(),
#    OS.get_model_name(),
# 
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
const GAME_SCREEN_RESOURCE_PATH := "res://src/panels/game_screen.tscn"

var loading_screen: Node
var camera_controller: CameraController
var canvas_layers: CanvasLayers
var main_menu: MainMenu
var game_screen: GameScreen
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
    if game_screen == null and \
            Time.elapsed_play_time_sec > 0.1:
        game_screen = Utils.add_scene( \
                self, \
                GAME_SCREEN_RESOURCE_PATH, \
                true, \
                false)
        game_screen.load_level(0)
        main_menu = Utils.add_scene( \
                canvas_layers.screen_layer, \
                MAIN_MENU_PATH, \
                true, \
                false)
    
    elif is_loading_screen_shown and \
            Time.elapsed_play_time_sec > 0.5:
        is_loading_screen_shown = false
        
        # Hide the loading screen.
        if loading_screen != null:
            canvas_layers.screen_layer.remove_child(loading_screen)
            loading_screen.queue_free()
            loading_screen = null
        
        main_menu.set_high_score(high_score)
        main_menu.visible = true
        
        canvas_layers.on_level_ready()
        
        if OS.get_name() == "HTML5":
            JavaScript.eval("window.onLevelReady()")
        
        Global.connect( \
                "go_to_main_menu", \
                self, \
                "_stop_game")
        Global.connect( \
                "game_over", \
                self, \
                "_record_high_score")
        Global.connect( \
                "go_to_game_screen", \
                self, \
                "_start_game")

func _start_game() -> void:
    game_screen.start_level(main_menu.selected_tier_index)
    main_menu.visible = false

func _stop_game() -> void:
    game_screen.stop_level()
    main_menu.visible = true

func _record_high_score(score: int) -> void:
    if score > high_score:
        high_score = score
        main_menu.set_high_score(high_score)
        if OS.get_name() == "HTML5":
            JavaScript.eval("window.setHighScore(%d)" % high_score)
