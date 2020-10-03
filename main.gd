extends Node
class_name Main

###############################################################################
### MAIN TODO LIST: ###
# 
# - Replace default images and sounds under assets/ and dist/.
# - Search for and replace occurrences of FIXME.
# 
###############################################################################

const LOADING_SCREEN_PATH := "res://src/loading_screen.tscn"
const STARTING_LEVEL_RESOURCE_PATH := "res://src/FIXME"

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
    # TODO: Figure out a better way of loading/parsing the level without
    #        blocking the main thread?
    
    if level == null and \
            Time.elapsed_play_time_sec > 0.25:
        # FIXME: Add a level.
        pass
#        # Start loading the level.
#        level = Utils.add_scene( \
#                self, \
#                STARTING_LEVEL_RESOURCE_PATH, \
#                true, \
#                false)
    
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
        
        # TODO: Move this player creation (and readiness recording) back into
        #       Level.
        # Add the player after removing the loading screen, since the camera
        # will track the player, which makes the loading screen look offset.
        var position := Vector2.ZERO
        # FIXME: Add player
        
        Global.canvas_layers.on_level_ready()
        
        if OS.get_name() == "HTML5":
            JavaScript.eval("window.onLevelReady()")
