extends Node2D
class_name CanvasLayers

var screen_layer: CanvasLayer
var menu_layer: CanvasLayer
var hud_layer: CanvasLayer
var annotation_layer: CanvasLayer

func _enter_tree() -> void:
    Global.canvas_layers = self
    
    _create_screen_layer()
    _create_menu_layer()
    _create_hud_layer()
    _create_annotation_layer()

func on_level_ready() -> void:
    pass

func _process(delta_sec: float) -> void:
    # Transform the annotation layer to follow the camera.
    var camera: Camera2D = Global.camera_controller.get_current_camera()
    if camera != null:
        annotation_layer.transform = get_canvas_transform()

func _create_screen_layer() -> void:
    screen_layer = CanvasLayer.new()
    screen_layer.layer = 1000
    Global.add_overlay_to_current_scene(screen_layer)

func _create_menu_layer() -> void:
    menu_layer = CanvasLayer.new()
    menu_layer.layer = 400
    Global.add_overlay_to_current_scene(menu_layer)
    
    # TODO: Add start and pause menus.

func _create_hud_layer() -> void:
    hud_layer = CanvasLayer.new()
    hud_layer.layer = 300
    Global.add_overlay_to_current_scene(hud_layer)
    
    # TODO: Add HUD content.

func _create_annotation_layer() -> void:
    annotation_layer = CanvasLayer.new()
    annotation_layer.layer = 100
    Global.add_overlay_to_current_scene(annotation_layer)
