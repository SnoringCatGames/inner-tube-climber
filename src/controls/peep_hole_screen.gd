tool
extends Node2D
class_name PeepHoleScreen

const PEEP_HOLE_IMAGE_SIZE := Vector2(256.0, 256.0)

const PEEP_HOLE_SIZE_DEFAULT := PEEP_HOLE_IMAGE_SIZE
const SCREEN_OPACITY_DEFAULT := 0.2

export var peep_hole_size := PEEP_HOLE_SIZE_DEFAULT setget \
        _set_peep_hole_size,_get_peep_hole_size
export var screen_opacity := SCREEN_OPACITY_DEFAULT setget \
        _set_screen_opacity,_get_screen_opacity

var _is_ready := false

func _ready() -> void:
    _is_ready = true
    Global.connect( \
            "display_resized", \
            self, \
            "_update_patches")
    _update_patches()

func _update_patches() -> void:
    var viewport_size := \
            Vector2(480.0, 480.0) if \
            Engine.editor_hint else \
            get_viewport().size
    var corner_patch_size := viewport_size - peep_hole_size * 0.5
    var horizontal_middle_patch_size := Vector2( \
            corner_patch_size.x, \
            peep_hole_size.y)
    var vertical_middle_patch_size := Vector2( \
            peep_hole_size.x, \
            corner_patch_size.y)
    
    # Update patch sizes.
    $CanvasLayer/Node2D/TopLeft.scale = corner_patch_size
    $CanvasLayer/Node2D/TopMiddle.scale = vertical_middle_patch_size
    $CanvasLayer/Node2D/TopRight.scale = corner_patch_size
    $CanvasLayer/Node2D/MiddleLeft.scale = horizontal_middle_patch_size
    $CanvasLayer/Node2D/Center.scale = peep_hole_size / PEEP_HOLE_IMAGE_SIZE
    $CanvasLayer/Node2D/MiddleRight.scale = horizontal_middle_patch_size
    $CanvasLayer/Node2D/BottomLeft.scale = corner_patch_size
    $CanvasLayer/Node2D/BottomMiddle.scale = vertical_middle_patch_size
    $CanvasLayer/Node2D/BottomRight.scale = corner_patch_size
    
    # Update patch positions.
    var corner_patch_offset := peep_hole_size * 0.5
    var scale_corner_offset_hack := corner_patch_size
    var scale_middle_offset_hack := peep_hole_size * 0.5
    $CanvasLayer/Node2D/TopLeft.position = Vector2( \
            -corner_patch_offset.x, \
            -corner_patch_offset.y)
    $CanvasLayer/Node2D/TopMiddle.position = Vector2( \
            0.0 + scale_middle_offset_hack.x, \
            -corner_patch_offset.y)
    $CanvasLayer/Node2D/TopRight.position = Vector2( \
            corner_patch_offset.x + scale_corner_offset_hack.x, \
            -corner_patch_offset.y)
    $CanvasLayer/Node2D/MiddleLeft.position = Vector2( \
            -corner_patch_offset.x, \
            0.0 + scale_middle_offset_hack.y)
    $CanvasLayer/Node2D/Center.position = Vector2.ZERO
    $CanvasLayer/Node2D/MiddleRight.position = Vector2( \
            corner_patch_offset.x + scale_corner_offset_hack.x, \
            0.0 + scale_middle_offset_hack.y)
    $CanvasLayer/Node2D/BottomLeft.position = Vector2( \
            -corner_patch_offset.x, \
            corner_patch_offset.y + scale_corner_offset_hack.y)
    $CanvasLayer/Node2D/BottomMiddle.position = Vector2( \
            0.0 + scale_middle_offset_hack.x, \
            corner_patch_offset.y + scale_corner_offset_hack.y)
    $CanvasLayer/Node2D/BottomRight.position = Vector2( \
            corner_patch_offset.x + scale_corner_offset_hack.x, \
            corner_patch_offset.y + scale_corner_offset_hack.y)
    
    # Update screen opacity.
    $CanvasLayer/Node2D/TopLeft.modulate.a = screen_opacity
    $CanvasLayer/Node2D/TopMiddle.modulate.a = screen_opacity
    $CanvasLayer/Node2D/TopRight.modulate.a = screen_opacity
    $CanvasLayer/Node2D/MiddleLeft.modulate.a = screen_opacity
    $CanvasLayer/Node2D/Center.modulate.a = screen_opacity
    $CanvasLayer/Node2D/MiddleRight.modulate.a = screen_opacity
    $CanvasLayer/Node2D/BottomLeft.modulate.a = screen_opacity
    $CanvasLayer/Node2D/BottomMiddle.modulate.a = screen_opacity
    $CanvasLayer/Node2D/BottomRight.modulate.a = screen_opacity

func _set_peep_hole_size(value: Vector2) -> void:
    peep_hole_size = value
    if _is_ready:
        _update_patches()

func _get_peep_hole_size() -> Vector2:
    return peep_hole_size

func _set_screen_opacity(value: float) -> void:
    screen_opacity = clamp(value, 0.0, 1.0)
    if _is_ready:
        _update_patches()

func _get_screen_opacity() -> float:
    return screen_opacity

func update_position(position: Vector2) -> void:
    $CanvasLayer/Node2D.position = position
