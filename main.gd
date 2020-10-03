extends Node
class_name Main

###############################################################################
### MAIN TODO LIST: ###
# 
# - Then, change bounce logic so that the held-down move-sideways button is
#   ignored after hitting a wall, until the button is lifted and pressed again.
# - Update level art:
#   - Make ground continuous with wall.
#   - Make four types of wall:
#     - wall-ground-corner-left
#     - wall-ground-corner-right
#     - wall-left
#     - wall-right
#   - Update walls to fade to solid at the edges.
# - Debug and adjust player mechanics.
#   - Is fall animation not triggering?
#   - Make movement satisfying!
# >- Take screenshot: of the player and level.
# - Add logic to dynamically create level from concatenating separate Tier
#   instances.
#   - Manually create the different Tier classes.
#   - And make it loop through the set of Tiers.
#   - Then add logic to destroy previous Tiers
#     - Don't allow falling to a previous Tier.
#       - A new Tier should have a long platform with no holes.
#       - No such thing as fall-through floors.
#   - Then add logic to keep track of the current height, the current yeti climb
#     speed, and the current yeti jump period.
# - Add the yeti art and behavior.
# - Add an unlock for double jump after a certain tier.
# >- Take screenshot: with the yeti.
# - Add music.
#   - Add support for sometimes changing the music when starting a new tier.
#   - Change every X tiers.
#   - Cycle through set playlist order.
#   - Create at least three songs:
#     - One simple, minimal song for the start, at the crevasse bottom.
#     - One lively, happy song for the main-menu screen, and part of intro
#       animation.
#     - One other up-beat minor song.
# - Search for and replace occurrences of FIXME.
# 
###############################################################################

const LOADING_SCREEN_PATH := "res://src/loading_screen.tscn"
const STARTING_LEVEL_RESOURCE_PATH := "res://src/level/level_1.tscn"
const PLAYER_RESOURCE_PATH := "res://src/player/tuber_player.tscn"

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
        
        # Add the player after removing the loading screen, since the camera
        # will track the player, which makes the loading screen look offset.
        var position := Vector2.ZERO
        var player: Player = Utils.add_scene( \
                self, \
                PLAYER_RESOURCE_PATH, \
                true, \
                true)
        player.position = position
        add_child(player)
        
        Global.canvas_layers.on_level_ready()
        
        if OS.get_name() == "HTML5":
            JavaScript.eval("window.onLevelReady()")
