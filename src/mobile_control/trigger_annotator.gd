# Draws an animation of a circle that expands and fades.
extends Annotator
class_name TriggerAnnotator

const STROKE_WIDTH := 24.0
const SECTOR_ARC_LENGTH := 8.0
const IS_FILLED := true

var trigger_position: Vector2
var time_start_sec: float
var duration_sec: float
var direction_angle: float
var radius_start: float
var radius_end: float
var base_color: Color
var opacity_start: float
var opacity_end: float
var easing: String

var progress: float

func _init( \
        trigger_position: Vector2, \
        time_start_sec: float, \
        duration_sec: float, \
        direction_angle: float,
        radius_start: float, \
        radius_end: float, \
        base_color: Color, \
        opacity_start: float, \
        opacity_end: float, \
        easing: String) -> void:
    self.trigger_position = trigger_position
    self.time_start_sec = time_start_sec
    self.duration_sec = duration_sec
    self.direction_angle = direction_angle
    self.radius_start = radius_start
    self.radius_end = radius_end
    self.base_color = base_color
    self.opacity_start = opacity_start
    self.opacity_end = opacity_end
    self.easing = easing

func _process(delta_sec: float) -> void:
    if progress < 1.0:
        update()
        progress = (Time.elapsed_play_time_actual_sec - time_start_sec) / \
                duration_sec
    else:
        emit_signal("finished")

func _draw() -> void:
    var eased_progress := Utils.ease_by_name(progress, easing)
    var opacity: float = lerp( \
            opacity_start, \
            opacity_end, \
            progress)
    var color := Color.from_hsv( \
            base_color.h, \
            base_color.s, \
            base_color.v, \
            opacity)
    var radius: float = lerp( \
            radius_start, \
            radius_end, \
            progress)
    
    if direction_angle != INF:
        DrawUtils.draw_triangle_with_one_arc_side( \
                self, \
                trigger_position, \
                radius, \
                direction_angle, \
                color, \
                IS_FILLED, \
                STROKE_WIDTH, \
                SECTOR_ARC_LENGTH)
    elif IS_FILLED:
        draw_circle( \
                trigger_position, \
                radius, \
                color)
    else:
        DrawUtils.draw_circle_outline( \
                self, \
                trigger_position, \
                radius, \
                color, \
                STROKE_WIDTH, \
                SECTOR_ARC_LENGTH)
