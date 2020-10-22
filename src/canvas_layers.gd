extends Node2D
class_name CanvasLayers

var DEBUG_PANEL_RESOURCE_PATH := "res://src/screens/debug_panel.tscn"

var game_screen_layer: CanvasLayer
var menu_screen_layer: CanvasLayer
var hud_layer: CanvasLayer
var annotation_layer: CanvasLayer

func _enter_tree() -> void:
    _create_menu_screen_layer()
    _create_hud_layer()
    _create_annotation_layer()
    _create_game_screen_layer()
    
    if Global.is_debug_panel_shown:
        set_debug_panel_visibility(true)

func _process(delta_sec: float) -> void:
    # Transform the annotation layer to follow the camera.
    var camera: Camera2D = Global.camera_controller.get_current_camera()
    if camera != null:
        annotation_layer.transform = get_canvas_transform()

func _create_game_screen_layer() -> void:
    game_screen_layer = CanvasLayer.new()
    game_screen_layer.layer = 100
    Global.add_overlay_to_current_scene(game_screen_layer)

func _create_menu_screen_layer() -> void:
    menu_screen_layer = CanvasLayer.new()
    menu_screen_layer.layer = 400
    Global.add_overlay_to_current_scene(menu_screen_layer)
    
    # TODO: Add start and pause menus.

func _create_hud_layer() -> void:
    hud_layer = CanvasLayer.new()
    hud_layer.layer = 300
    Global.add_overlay_to_current_scene(hud_layer)
    
    # TODO: Add HUD content.

func _create_annotation_layer() -> void:
    annotation_layer = CanvasLayer.new()
    annotation_layer.layer = 200
    Global.add_overlay_to_current_scene(annotation_layer)

func set_debug_panel_visibility(is_visible: bool) -> void:
    Global.is_debug_panel_shown = is_visible
    
    if is_visible and Global.debug_panel == null:
        Global.debug_panel = Utils.add_scene( \
                hud_layer, \
                DEBUG_PANEL_RESOURCE_PATH, \
                true, \
                true)
        Global.debug_panel.z_index = 1000
    elif !is_visible and Global.debug_panel != null:
        hud_layer.remove_child(Global.debug_panel)
        Global.debug_panel.queue_free()
        Global.debug_panel = null
