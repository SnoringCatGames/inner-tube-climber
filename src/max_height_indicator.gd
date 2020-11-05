extends Annotator
class_name MaxHeightIndicator

const DEFAULT_WALL_POSITION_X := 32.0 * 6.0
const BASE_DISTANCE_FROM_CONE_END_POINT_TO_CIRCLE_CENTER := 15.0
const BASE_RADIUS := 6.0
const SECTOR_ARC_LENGTH := 4.0

const PULSE_DURATION_SEC := 0.3
const PULSE_START_SCALE := 1.0
const PULSE_END_SCALE := 4.0
const PULSE_START_OPACITY := 1.0
const PULSE_END_OPACITY := 0.0

var color: Color
var radius: float
var origin_offset: float
var distance_from_cone_end_point_to_circle_center: float
var pulses: bool

var previous_max_height := -INF
var did_max_height_change_last_frame := false
var is_pulse_active := false
var pulse_start_time := -INF

func _init( \
        color: Color, \
        extra_radius: float, \
        extra_distance_from_cone_end_point_to_circle_center: float, \
        origin_offset: float, \
        pulses: bool) -> void:
    self.color = color
    self.radius = BASE_RADIUS + extra_radius
    self.origin_offset = origin_offset
    self.distance_from_cone_end_point_to_circle_center = \
            BASE_DISTANCE_FROM_CONE_END_POINT_TO_CIRCLE_CENTER + \
            extra_distance_from_cone_end_point_to_circle_center
    self.pulses = pulses
    z_index = 1

func check_for_updates(max_height: float) -> void:
    var current_time := Time.elapsed_play_time_actual_sec
    
    var has_max_height_changed := max_height != previous_max_height
    previous_max_height = max_height
    
    if !did_max_height_change_last_frame and has_max_height_changed:
        pulse_start_time = current_time
    
    did_max_height_change_last_frame = has_max_height_changed
    
    if has_max_height_changed or is_pulse_active:
        is_pulse_active = \
                pulses and \
                pulse_start_time + PULSE_DURATION_SEC >= current_time
        update()

func _draw() -> void:
    var left_end_point := \
            Vector2(-DEFAULT_WALL_POSITION_X - origin_offset, \
                    -previous_max_height)
    var left_center := \
            left_end_point + \
            Vector2(-distance_from_cone_end_point_to_circle_center, 0.0)
    var right_end_point := \
            Vector2(DEFAULT_WALL_POSITION_X + origin_offset, \
                    -previous_max_height)
    var right_center := \
            right_end_point + \
            Vector2(distance_from_cone_end_point_to_circle_center, 0.0)
    
    # Draw pulses.
    var pulse_progress := \
            (Time.elapsed_play_time_actual_sec - pulse_start_time) / \
            PULSE_DURATION_SEC
    if is_pulse_active and pulse_progress < 1.0:
        var pulse_scale: float = lerp( \
                PULSE_START_SCALE, \
                PULSE_END_SCALE, \
                pulse_progress)
        var pulse_distance_from_cone_end_point_to_circle_center := \
                distance_from_cone_end_point_to_circle_center * pulse_scale
        var pulse_radius := \
                radius * pulse_scale
        var pulse_opacity: float = lerp( \
                PULSE_START_OPACITY, \
                PULSE_END_OPACITY, \
                pulse_progress)
        var pulse_color := Color.from_hsv( \
                color.h, \
                color.s, \
                color.v, \
                pulse_opacity)
        var left_pulse_center := left_center
        var left_pulse_end_point := \
                left_pulse_center + \
                Vector2(pulse_distance_from_cone_end_point_to_circle_center, \
                        0.0)
        var right_pulse_center := right_center
        var right_pulse_end_point := \
                right_pulse_center + \
                Vector2(-pulse_distance_from_cone_end_point_to_circle_center, \
                        0.0)
        
        DrawUtils.draw_ice_cream_cone( \
                self, \
                left_pulse_end_point, \
                left_pulse_center, \
                pulse_radius, \
                pulse_color, \
                true, \
                0.0, \
                SECTOR_ARC_LENGTH)
        DrawUtils.draw_ice_cream_cone( \
                self, \
                right_pulse_end_point, \
                right_pulse_center, \
                pulse_radius, \
                pulse_color, \
                true, \
                0.0, \
                SECTOR_ARC_LENGTH)
    
    # Draw indicators.
    DrawUtils.draw_ice_cream_cone( \
            self, \
            left_end_point, \
            left_center, \
            radius, \
            color, \
            true, \
            0.0, \
            SECTOR_ARC_LENGTH)
    DrawUtils.draw_ice_cream_cone( \
            self, \
            right_end_point, \
            right_center, \
            radius, \
            color, \
            true, \
            0.0, \
            SECTOR_ARC_LENGTH)
