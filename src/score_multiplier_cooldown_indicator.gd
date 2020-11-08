extends Annotator
class_name ScoreMultiplierCooldownIndicator

const MAIN_FONT_NORMAL: Font = \
        preload("res://assets/fonts/main_font_normal.tres")

const COOLDOWN_DURATION_SEC := 4.0

const CORNER_OFFSET := Vector2(72.0, 72.0)

const LABEL_SCALE := Vector2(1.2, 1.2)
const LABEL_OFFSET := Vector2(-2.8, -4.0)
const RADIUS := 18.0
const NEXT_STEP_STROKE_WIDTH_START := 1.0
const NEXT_STEP_STROKE_WIDTH_END := 7.0
const SECTOR_ARC_LENGTH := 4.0
var COOLDOWN_COLOR: Color = Constants.INDICATOR_GREEN_COLOR
var NEXT_STEP_COLOR: Color = Constants.INDICATOR_BLUE_COLOR
var TEXT_COLOR := Color.from_hsv(0.0, 0.0, 1.0, 1.0)
var TEXT_OUTLINE_COLOR := Color.from_hsv(0.0, 0.0, 0.0, 0.7)
const INACTIVE_OPACITY := 0.3

const NEXT_STEP_PULSE_DURATION_SEC := 0.3
const NEXT_STEP_PULSE_RADIUS_START := 18.0
const NEXT_STEP_PULSE_RADIUS_END := 28.0
const NEXT_STEP_PULSE_OPACITY_START := 1.0
const NEXT_STEP_PULSE_OPACITY_END := 0.0
var NEXT_STEP_PULSE_COLOR: Color = Constants.INDICATOR_BLUE_COLOR

var FIRST_PULSE_HEARTBEAT_DURATION_RATIO := 0.5
var SECOND_PULSE_HEARTBEAT_DURATION_RATIO := 0.4
var INTER_PULSE_HEARTBEAT_GAP_RATIO := 0.1
var HEARTBEAT_OPACITY_MAX := 0.3
var HEARTBEAT_OPACITY_MIN := 0.99
var HEARTBEAT_COLOR := NEXT_STEP_COLOR

const MULTIPLIER_VALUES_AND_STEP_DURATIONS: Array = [
    {
        multiplier = 1,
        step_duration_sec = 16.0,
        heartbeat_pulse_bpm = 40.0,
        heartbeat_radius_ratio = 1.15,
        heartbeat_post_second_pulse_gap_ratio = 0.6,
    },
    {
        multiplier = 2,
        step_duration_sec = 32.0,
        heartbeat_pulse_bpm = 52.0,
        heartbeat_radius_ratio = 1.2,
        heartbeat_post_second_pulse_gap_ratio = 0.55,
    },
    {
        multiplier = 4,
        step_duration_sec = 64.0,
        heartbeat_pulse_bpm = 72.0,
        heartbeat_radius_ratio = 1.25,
        heartbeat_post_second_pulse_gap_ratio = 0.5,
    },
    {
        multiplier = 8,
        step_duration_sec = 128.0,
        heartbeat_pulse_bpm = 100.0,
        heartbeat_radius_ratio = 1.3,
        heartbeat_post_second_pulse_gap_ratio = 0.45,
    },
    {
        multiplier = 16,
        step_duration_sec = INF,
        heartbeat_pulse_bpm = 120.0,
        heartbeat_radius_ratio = 1.35,
        heartbeat_post_second_pulse_gap_ratio = 0.4,
    },
]

var center := Vector2.INF
var multiplier_label: Label

var is_multiplier_active := false
var cooldown_ratio := 0.0
var next_step_ratio := 0.0
var is_multiplier_maxed := false

var step_index := 0
var step_start_actual_time_sec := -INF
var step_start_modified_time_sec := -INF
var cooldown_start_time_sec := -INF
var previous_max_height := -INF

var multiplier: float setget ,_get_multiplier

func _get_multiplier() -> float:
    return MULTIPLIER_VALUES_AND_STEP_DURATIONS[step_index].multiplier

func _enter_tree() -> void:
    multiplier_label = Label.new()
    multiplier_label.add_font_override("font", MAIN_FONT_NORMAL)
    multiplier_label.add_color_override("font_color", TEXT_COLOR)
    multiplier_label.add_color_override( \
            "font_color_shadow", TEXT_OUTLINE_COLOR)
    multiplier_label.rect_scale = LABEL_SCALE
    multiplier_label.add_constant_override("shadow_as_outline", 1)
    add_child(multiplier_label)
    
    Global.connect( \
            "display_resized", \
            self, \
            "_on_display_resized")
    _on_display_resized()

func _on_display_resized() -> void:
    var offset := Vector2()
    offset.x = max(CORNER_OFFSET.x, Utils.get_safe_area_margin_right())
    offset.y = max(CORNER_OFFSET.y, Utils.get_safe_area_margin_top())
    
    center.x = get_viewport().size.x - offset.x
    center.y = offset.y

func check_for_updates(max_height: float) -> void:
    var current_time_sec := Time.elapsed_play_time_modified_sec
    
    var has_max_height_changed := max_height != previous_max_height
    previous_max_height = max_height
    
    var has_cooldown_expired := \
            cooldown_start_time_sec == -INF or \
            (cooldown_start_time_sec + COOLDOWN_DURATION_SEC <= \
                    current_time_sec)
    
    var step_duration_sec: float = \
            MULTIPLIER_VALUES_AND_STEP_DURATIONS[step_index].step_duration_sec
    var has_step_duration_passed := \
            step_start_modified_time_sec != -INF and \
            (step_start_modified_time_sec + step_duration_sec <= \
                    current_time_sec)
    
    if has_max_height_changed:
        if !is_multiplier_active:
            step_start_actual_time_sec = Time.elapsed_play_time_actual_sec
            step_start_modified_time_sec = current_time_sec
        is_multiplier_active = true
        cooldown_start_time_sec = current_time_sec
        has_cooldown_expired = false
        update()
    
    if has_cooldown_expired:
        stop_cooldown()
        
    elif has_step_duration_passed:
        step_index = min( \
                step_index + 1, \
                MULTIPLIER_VALUES_AND_STEP_DURATIONS.size() - 1)
        step_start_actual_time_sec = Time.elapsed_play_time_actual_sec
        step_start_modified_time_sec = current_time_sec
        is_multiplier_maxed = \
                step_index == MULTIPLIER_VALUES_AND_STEP_DURATIONS.size() - 1
        update()
    
    cooldown_ratio = \
            (current_time_sec - cooldown_start_time_sec) / \
                    COOLDOWN_DURATION_SEC if \
            is_multiplier_active else \
            0.0
    next_step_ratio = \
            (current_time_sec - step_start_modified_time_sec) / \
                    step_duration_sec if \
            is_multiplier_active else \
            0.0
    
    if is_multiplier_active:
        update()

func stop_cooldown() -> void:
    is_multiplier_active = false
    step_start_actual_time_sec = -INF
    step_start_modified_time_sec = -INF
    cooldown_start_time_sec = -INF
    step_index = 0
    update()

func _draw() -> void:
    var step_config: Dictionary = \
            MULTIPLIER_VALUES_AND_STEP_DURATIONS[step_index]
    
    var cooldown_color := \
            COOLDOWN_COLOR if \
            is_multiplier_active else \
            Color.from_hsv( \
                    COOLDOWN_COLOR.h, \
                    COOLDOWN_COLOR.s, \
                    COOLDOWN_COLOR.v, \
                    INACTIVE_OPACITY)
    var next_step_color := \
            NEXT_STEP_COLOR if \
            is_multiplier_active else \
            Color.from_hsv( \
                    NEXT_STEP_COLOR.h, \
                    NEXT_STEP_COLOR.s, \
                    NEXT_STEP_COLOR.v, \
                    INACTIVE_OPACITY)
    var text_color := \
            TEXT_COLOR if \
            is_multiplier_active else \
            Color.from_hsv( \
                    TEXT_COLOR.h, \
                    TEXT_COLOR.s, \
                    TEXT_COLOR.v, \
                    INACTIVE_OPACITY)
    
    # Draw the next-step pulse?
    var pulse_progress := \
            (Time.elapsed_play_time_actual_sec - \
                    step_start_actual_time_sec) / \
            NEXT_STEP_PULSE_DURATION_SEC
    if pulse_progress < 1.0:
        pulse_progress = Utils.ease_by_name( \
                pulse_progress, \
                "ease_out")
        var pulse_radius: float = lerp( \
                NEXT_STEP_PULSE_RADIUS_START, \
                NEXT_STEP_PULSE_RADIUS_END, \
                pulse_progress)
        var pulse_opacity: float = lerp( \
                NEXT_STEP_PULSE_OPACITY_START, \
                NEXT_STEP_PULSE_OPACITY_END, \
                pulse_progress)
        var pulse_color := Color.from_hsv( \
                NEXT_STEP_PULSE_COLOR.h, \
                NEXT_STEP_PULSE_COLOR.s, \
                NEXT_STEP_PULSE_COLOR.v, \
                pulse_opacity)
        draw_circle( \
                center, \
                pulse_radius, \
                pulse_color)
    
    var radius: float
    var label_scale: float
    if is_multiplier_active:
        # Draw a double-pulse heartbeat circle.
        
        var heartbeat_pulse_period_sec: float = \
                60.0 / step_config.heartbeat_pulse_bpm
        var heartbeat_radius_min := RADIUS
        var heartbeat_radius_max: float = \
                RADIUS * step_config.heartbeat_radius_ratio
        var heartbeat_pulses_first_part_duration_sec: float = \
                heartbeat_pulse_period_sec * \
                (1 - step_config.heartbeat_post_second_pulse_gap_ratio)
        
        var first_pulse_duration_sec := \
                FIRST_PULSE_HEARTBEAT_DURATION_RATIO * \
                heartbeat_pulses_first_part_duration_sec
        var second_pulse_duration_sec := \
                SECOND_PULSE_HEARTBEAT_DURATION_RATIO * \
                heartbeat_pulses_first_part_duration_sec
        var inter_pulse_heartbeat_gap_sec := \
                INTER_PULSE_HEARTBEAT_GAP_RATIO * \
                heartbeat_pulses_first_part_duration_sec
        var second_pulse_delay_sec := \
                heartbeat_pulse_period_sec - second_pulse_duration_sec
        var first_pulse_delay_sec := \
                second_pulse_delay_sec - \
                inter_pulse_heartbeat_gap_sec - \
                first_pulse_duration_sec
        assert(first_pulse_delay_sec >= 0.0)
        
        var elapsed_step_time_actual_sec := \
                Time.elapsed_play_time_actual_sec - step_start_actual_time_sec
        var elapsed_heartbeat_time_sec := \
                fmod(elapsed_step_time_actual_sec, heartbeat_pulse_period_sec)
        var is_before_first_pulse := \
                elapsed_heartbeat_time_sec < first_pulse_delay_sec
        var is_in_first_pulse := \
                elapsed_heartbeat_time_sec >= first_pulse_delay_sec and \
                elapsed_heartbeat_time_sec <= \
                        first_pulse_delay_sec + first_pulse_duration_sec
        var is_in_second_pulse := \
                elapsed_heartbeat_time_sec >= second_pulse_delay_sec and \
                elapsed_heartbeat_time_sec <= \
                        second_pulse_delay_sec + second_pulse_duration_sec
        var is_between_pulses := \
                elapsed_heartbeat_time_sec > \
                        first_pulse_delay_sec + first_pulse_duration_sec and \
                elapsed_heartbeat_time_sec < second_pulse_delay_sec
        var is_after_second_pulse := \
                elapsed_heartbeat_time_sec > \
                        second_pulse_delay_sec + second_pulse_duration_sec
        
        var heartbeat_radius_progress: float
        if is_in_first_pulse:
            heartbeat_radius_progress = \
                    (elapsed_heartbeat_time_sec - first_pulse_delay_sec) / \
                    first_pulse_duration_sec
        elif is_in_second_pulse:
            heartbeat_radius_progress = \
                    (elapsed_heartbeat_time_sec - second_pulse_delay_sec) / \
                    second_pulse_duration_sec
        elif is_before_first_pulse or \
                is_between_pulses or \
                is_after_second_pulse:
            heartbeat_radius_progress = 0.0
        else:
            Utils.error()
            heartbeat_radius_progress = 0.0
        heartbeat_radius_progress = \
                Utils.ease_by_name(heartbeat_radius_progress, "ease_out")
        heartbeat_radius_progress = sin(heartbeat_radius_progress * PI)
        
        var heartbeat_radius: float = lerp( \
                heartbeat_radius_min, \
                heartbeat_radius_max, \
                heartbeat_radius_progress)
        var heartbeat_opacity: float = lerp( \
                HEARTBEAT_OPACITY_MIN, \
                HEARTBEAT_OPACITY_MAX, \
                heartbeat_radius_progress)
        var heartbeat_color := Color.from_hsv( \
                HEARTBEAT_COLOR.h, \
                HEARTBEAT_COLOR.s, \
                HEARTBEAT_COLOR.v, \
                heartbeat_opacity)
        
        radius = heartbeat_radius
        label_scale = lerp( \
                1.0, \
                step_config.heartbeat_radius_ratio, \
                heartbeat_radius_progress)
        
    else:
        radius = RADIUS
        label_scale = 1.0
    
    if is_multiplier_active:
        # Draw cooldown progress (circle center / pie slice).
        DrawUtils.draw_pie_slice( \
                self, \
                center, \
                radius, \
                1.0 - cooldown_ratio, \
                cooldown_color, \
                SECTOR_ARC_LENGTH)
    else:
        draw_circle( \
                center, \
                radius, \
                cooldown_color)
    
    if is_multiplier_active:
        # Draw step progress (circle border).
        if is_multiplier_maxed:
            var next_step_stroke_width := NEXT_STEP_STROKE_WIDTH_END
            DrawUtils.draw_circle_outline( \
                    self, \
                    center, \
                    radius, \
                    next_step_color, \
                    next_step_stroke_width, \
                    SECTOR_ARC_LENGTH)
        else:
            var start_angle := -PI / 2.0
            var end_angle := start_angle + 2.0 * PI * next_step_ratio
            var next_step_stroke_width: float = lerp( \
                    NEXT_STEP_STROKE_WIDTH_START, \
                    NEXT_STEP_STROKE_WIDTH_END, \
                    next_step_ratio)
            DrawUtils.draw_arc( \
                    self, \
                    center, \
                    radius, \
                    start_angle, \
                    end_angle, \
                    next_step_color, \
                    next_step_stroke_width, \
                    SECTOR_ARC_LENGTH)
    
    # Draw multiplier label.
    var multiplier_text: String = "x%1d" % step_config.multiplier
    multiplier_label.text = multiplier_text
    multiplier_label.add_color_override("font_color", text_color)
    multiplier_label.rect_scale = LABEL_SCALE * label_scale
    multiplier_label.rect_position = \
            center - \
            MAIN_FONT_NORMAL.get_string_size(multiplier_text) / 2.0 - \
            LABEL_SCALE * label_scale * label_scale + \
            LABEL_OFFSET * label_scale * label_scale
