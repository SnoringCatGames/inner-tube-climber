extends Node
class_name Main

###############################################################################
### MAIN TODO LIST: ###
# 
# >- Take screenshot?
# - Render current height in a HUD element.
# - Add overlays to indicate keys to press.
#   - Configured in TIERS_CONFIG.
#   - Rendered dynamically in level as overlays.
# >- Take screenshot?
# - Create a bunch of tiers that enable satisfying skill progression.
# - Create a flag for setting the tier you want to start from (select from main
#   menu).
# >- Take screenshot?
# - Update art:
#   - Make ground continuous with wall.
#   - Make four types of wall:
#     - wall-ground-corner-left
#     - wall-ground-corner-right
#     - wall-left
#     - wall-right
#   - Update walls to fade to solid at the edges.
#   - Add shading to the tuber player.
#   - Smooth sharp elbow angle on tuber jump-rise.
#   - Put more thought into the ice and snow platform art.
#   - Put more thought into the background?
# - Will need to introduce solid, not-jump-throughable platforms, in order to
#   make the wall bouncing really exciting and meaningful.
# >- Take screenshot?
# - Add an unlock for face-plant-bounce-off-tube-higher-jump after a certain
#   tier.
# - Add an unlock for double jump after a certain tier.
# >- Take screenshot?
# - Add music.
#   - Add support for sometimes changing the music when starting a new tier.
#   - Change every X tiers.
#   - Cycle through set playlist order.
#   - Create at least three songs:
#     - One simple, minimal song for the start, at the crevasse bottom.
#     - One lively, happy song for the main-menu screen, and part of intro
#       animation.
#     - One other up-beat minor song.
#     - Add dies irae as game-over/you-lose sound.
# - Update music to cross fade, rather than stopping/starting abruptly.
# - Balance volumes of sfx and music.
# - Create alternate art for foreground and background for different tiers, in
#   order to add more variety.
# - Increase music playback speed when camera pan speed increases.
# - Search for and replace occurrences of FIXME.
# 
###############################################################################

const LOADING_SCREEN_PATH := "res://src/loading_screen.tscn"
const STARTING_LEVEL_RESOURCE_PATH := "res://src/level/level.tscn"

var loading_screen: Node
var camera_controller: CameraController
var canvas_layers: CanvasLayers
var level: Level
var is_loading_screen_shown := true

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
    
    elif is_loading_screen_shown and \
            Global.is_level_ready and \
            Time.elapsed_play_time_sec > 0.5:
        is_loading_screen_shown = false
        level.visible = true
        
        # Hide the loading screen.
        if loading_screen != null:
            canvas_layers.screen_layer.remove_child(loading_screen)
            loading_screen.queue_free()
            loading_screen = null
        
        Global.canvas_layers.on_level_ready()
        
        if OS.get_name() == "HTML5":
            JavaScript.eval("window.onLevelReady()")
