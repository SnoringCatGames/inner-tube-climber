extends Node

var canvas_layers: CanvasLayers
var current_level: Level
var camera_controller: CameraController

var is_level_ready := false

func get_is_paused() -> bool:
    return get_tree().paused

func pause() -> void:
    get_tree().paused = true

func unpause() -> void:
    get_tree().paused = false

func add_overlay_to_current_scene(node: Node) -> void:
    get_tree().get_current_scene().add_child(node)
