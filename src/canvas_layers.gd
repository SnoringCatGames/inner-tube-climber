extends Node2D
class_name CanvasLayers

var DEBUG_PANEL_RESOURCE_PATH := "res://src/controls/debug_panel.tscn"

var game_screen_layer: CanvasLayer
var menu_screen_layer: CanvasLayer
var hud_layer: CanvasLayer
var annotation_layer: CanvasLayer

var is_debug_panel_shown := true setget \
        _set_is_debug_panel_shown, _get_is_debug_panel_shown

func _enter_tree() -> void:
    _create_menu_screen_layer()
    _create_hud_layer()
    _create_annotation_layer()
    _create_game_screen_layer()

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
    
    Global.debug_panel = Utils.add_scene( \
            hud_layer, \
            DEBUG_PANEL_RESOURCE_PATH, \
            true, \
            true)
    Global.debug_panel.z_index = 1000
    _set_is_debug_panel_shown(true)

func _create_annotation_layer() -> void:
    annotation_layer = CanvasLayer.new()
    annotation_layer.layer = 200
    Global.add_overlay_to_current_scene(annotation_layer)

func _set_is_debug_panel_shown(is_visible: bool) -> void:
    is_debug_panel_shown = is_visible
    Global.debug_panel.visible = is_visible

func _get_is_debug_panel_shown() -> bool:
    return is_debug_panel_shown
