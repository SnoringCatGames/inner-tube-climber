extends Annotator
class_name ScoreMultiplierCooldownIndicator

const COOLDOWN_DURATION_SEC := 4.0

const CORNER_OFFSET := Vector2(72.0, 72.0)

const LABEL_SCALE := Vector2(1.2, 1.2)
const LABEL_OFFSET := Vector2(-2.8, -3.0)
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
const NEXT_STEP_PULSE_RADIUS_END := 38.0
const NEXT_STEP_PULSE_OPACITY_START := 1.0
const NEXT_STEP_PULSE_OPACITY_END := 0.0
var NEXT_STEP_PULSE_COLOR: Color = Constants.INDICATOR_BLUE_COLOR

var FIRST_PULSE_HEARTBEAT_DURATION_RATIO := 0.5
var SECOND_PULSE_HEARTBEAT_DURATION_RATIO := 0.4
var INTER_PULSE_HEARTBEAT_GAP_RATIO := 0.1
var HEARTBEAT_OPACITY_MAX := 0.3
var HEARTBEAT_OPACITY_MIN := 0.99

var NEXT_STEP_RATIO_TWEEN_DURATION_SEC := 0.2

const SHIVER_PARAMS := [
    {
        shiver_offset_max = 0.0,
        shiver_per_sec = 0.00001,
    },
    {
        shiver_offset_max = 1.0,
        shiver_per_sec = 20,
    },
    {
        shiver_offset_max = 1.5,
        shiver_per_sec = 40,
    },
    {
        shiver_offset_max = 1.8,
        shiver_per_sec = 60,
    },
    {
        shiver_offset_max = 0.0,
        shiver_per_sec = 0.00001,
    },
]

const MULTIPLIER_VALUES_AND_STEP_DURATIONS: Array = [
    {
        multiplier = 1,
        step_height = 1600.0,
        heartbeat_pulse_bpm = 40.0,
        heartbeat_radius_ratio = 1.15,
        heartbeat_post_second_pulse_gap_ratio = 0.6,
        indicator_saturation_ratio = 1.0,
        indicator_value_ratio = 1.0,
        audio_speed = 1.0,
    },
    {
        multiplier = 2,
        step_height = 3200.0,
        heartbeat_pulse_bpm = 52.0,
        heartbeat_radius_ratio = 1.21,
        heartbeat_post_second_pulse_gap_ratio = 0.55,
        indicator_saturation_ratio = 0.8,
        indicator_value_ratio = 1.2,
        audio_speed = 1.2,
    },
    {
        multiplier = 4,
        step_height = 6400.0,
        heartbeat_pulse_bpm = 72.0,
        heartbeat_radius_ratio = 1.28,
        heartbeat_post_second_pulse_gap_ratio = 0.5,
        indicator_saturation_ratio = 0.6,
        indicator_value_ratio = 1.4,
        audio_speed = 1.45,
    },
    {
        multiplier = 8,
        step_height = 12800.0,
        heartbeat_pulse_bpm = 100.0,
        heartbeat_radius_ratio = 1.35,
        heartbeat_post_second_pulse_gap_ratio = 0.45,
        indicator_saturation_ratio = 0.4,
        indicator_value_ratio = 1.6,
        audio_speed = 1.75,
    },
    {
        multiplier = 16,
        step_height = INF,
        heartbeat_pulse_bpm = 120.0,
        heartbeat_radius_ratio = 1.42,
        heartbeat_post_second_pulse_gap_ratio = 0.4,
        indicator_saturation_ratio = 0.2,
        indicator_value_ratio = 1.8,
        audio_speed = 2.1,
    },
]

var next_step_ratio_tween := Tween.new()
var next_step_tween_ratio := 0.0
var is_next_step_ratio_tween_active := false

var current_center := Vector2.INF
var shiver_center := Vector2.INF
var multiplier_label: Label

var is_multiplier_active := false
var cooldown_ratio := 0.0
var next_step_ratio := 0.0
var is_multiplier_maxed := false

var step_index := 0
var step_start_actual_time_sec := -INF
var step_start_height := -INF
var cooldown_start_time_sec := -INF
var last_shiver_time_sec := -INF
var last_shiver_param_index := -INF
var previous_max_platform_height := -INF
var previous_latest_platform_height := -INF

var multiplier: float setget ,_get_multiplier

func _get_multiplier() -> float:
    return MULTIPLIER_VALUES_AND_STEP_DURATIONS[step_index].multiplier

func _enter_tree() -> void:
    multiplier_label = Label.new()
    multiplier_label.add_font_override("font", Constants.MAIN_FONT_NORMAL)
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
    
    next_step_ratio_tween.connect( \
            "tween_completed", \
            self, \
            "_on_next_step_ratio_tween_completed")
    add_child(next_step_ratio_tween)

func _on_display_resized() -> void:
    var offset := Vector2()
    offset.x = max(CORNER_OFFSET.x, Utils.get_safe_area_margin_right())
    offset.y = max(CORNER_OFFSET.y, Utils.get_safe_area_margin_top())
    
    current_center.x = get_viewport().size.x - offset.x
    current_center.y = offset.y
    update()

func check_for_updates( \
        max_platform_height: float, \
        latest_platform_height: float, \
        is_player_in_air: bool) -> void:
    var has_max_platform_height_increased := \
            max_platform_height > previous_max_platform_height + 0.1
    var has_latest_platform_height_decreased := \
            latest_platform_height < previous_latest_platform_height - 0.1
    previous_max_platform_height = max_platform_height
    previous_latest_platform_height = latest_platform_height
    
    # Don't stop the cooldown if the player is still in the air.
    var has_cooldown_expired := \
            cooldown_start_time_sec == -INF or \
            ((cooldown_start_time_sec + COOLDOWN_DURATION_SEC <= \
                    Time.elapsed_play_time_modified_sec) and \
            !is_player_in_air)
    
    var step_config: Dictionary = \
            MULTIPLIER_VALUES_AND_STEP_DURATIONS[step_index]
    
    var step_height: float = step_config.step_height
    var has_step_duration_passed := \
            step_start_height != -INF and \
            max_platform_height - step_start_height > step_height
    
    if has_max_platform_height_increased:
        if !is_multiplier_active:
            step_start_actual_time_sec = Time.elapsed_play_time_actual_sec
            step_start_height = max_platform_height
        is_multiplier_active = true
        cooldown_start_time_sec = Time.elapsed_play_time_modified_sec
        has_cooldown_expired = false
        update()
    
    if has_cooldown_expired or has_latest_platform_height_decreased:
        stop_cooldown()
        
    elif has_step_duration_passed:
        step_index = min( \
                step_index + 1, \
                MULTIPLIER_VALUES_AND_STEP_DURATIONS.size() - 1)
        step_config = MULTIPLIER_VALUES_AND_STEP_DURATIONS[step_index]
        step_start_actual_time_sec = Time.elapsed_play_time_actual_sec
        step_start_height = max_platform_height
        is_multiplier_maxed = \
                step_index == MULTIPLIER_VALUES_AND_STEP_DURATIONS.size() - 1
        Audio.set_playback_speed(step_config.audio_speed)
        update()
    
    if is_multiplier_active:
        cooldown_ratio = \
                (Time.elapsed_play_time_modified_sec - \
                        cooldown_start_time_sec) / \
                COOLDOWN_DURATION_SEC
        # Don't stop the cooldown if the player is still in the air.
        if is_player_in_air:
            cooldown_ratio = min(cooldown_ratio, 0.97)
    else:
        cooldown_ratio = 0.0
    
    var previous_next_step_ratio := next_step_ratio
    next_step_ratio = \
            (max_platform_height - step_start_height) / step_height if \
            is_multiplier_active else \
            0.0
    var has_next_step_ratio_changed := \
            previous_next_step_ratio != next_step_ratio
    
    var current_shiver_param_index := \
            4 if \
            cooldown_ratio == 0.0 else \
            (0 if \
            cooldown_ratio < 0.25 else \
            (1 if \
            cooldown_ratio < 0.5 else \
            (2 if \
            cooldown_ratio < 0.75 else \
            3)))
    var shiver_params: Dictionary = SHIVER_PARAMS[current_shiver_param_index]
    var is_time_for_next_shiver: float = \
            last_shiver_time_sec + 1.0 / shiver_params.shiver_per_sec < \
            Time.elapsed_play_time_actual_sec
    var is_time_for_next_shiver_param := \
            last_shiver_param_index != current_shiver_param_index
    last_shiver_param_index = current_shiver_param_index
    if is_time_for_next_shiver or is_time_for_next_shiver_param:
        shiver_params = SHIVER_PARAMS[current_shiver_param_index]
        last_shiver_time_sec = Time.elapsed_play_time_actual_sec
        var shiver_offset: Vector2 = \
                -Vector2.ONE * shiver_params.shiver_offset_max + \
                Vector2(randf(), randf()) * \
                        shiver_params.shiver_offset_max * 2.0
        shiver_center = current_center + shiver_offset
    
    if has_next_step_ratio_changed:
        is_next_step_ratio_tween_active = true
        next_step_ratio_tween.stop(self)
        next_step_ratio_tween.interpolate_property( \
                self, \
                "next_step_tween_ratio", \
                next_step_tween_ratio, \
                next_step_ratio, \
                NEXT_STEP_RATIO_TWEEN_DURATION_SEC, \
                Tween.TRANS_QUAD, \
                Tween.EASE_IN_OUT)
        next_step_ratio_tween.start()
    
    if is_multiplier_active:
        update()
    
    if is_next_step_ratio_tween_active:
        update()

func stop_cooldown() -> void:
    next_step_ratio_tween.stop(self)
    next_step_tween_ratio = 0.0
    is_next_step_ratio_tween_active = false
    is_multiplier_active = false
    step_start_actual_time_sec = -INF
    step_start_height = -INF
    cooldown_start_time_sec = -INF
    last_shiver_time_sec = -INF
    last_shiver_param_index = -INF
    step_index = 0
    shiver_center = current_center
    cooldown_ratio = 0.0
    next_step_ratio = 0.0
    is_multiplier_maxed = false
    Audio.set_playback_speed(1.0)
    update()

func _on_next_step_ratio_tween_completed() -> void:
    is_next_step_ratio_tween_active = false

func _draw() -> void:
    var step_config: Dictionary = \
            MULTIPLIER_VALUES_AND_STEP_DURATIONS[step_index]
    
    var cooldown_saturation := clamp( \
            COOLDOWN_COLOR.s * step_config.indicator_saturation_ratio, \
            0.0, \
            1.0)
    var cooldown_value := clamp( \
            COOLDOWN_COLOR.v * step_config.indicator_value_ratio, \
            0.0, \
            1.0)
    var cooldown_color := \
            Color.from_hsv( \
                    COOLDOWN_COLOR.h, \
                    cooldown_saturation, \
                    cooldown_value, \
                    COOLDOWN_COLOR.a) if \
            is_multiplier_active else \
            Color.from_hsv( \
                    COOLDOWN_COLOR.h, \
                    COOLDOWN_COLOR.s, \
                    COOLDOWN_COLOR.v, \
                    INACTIVE_OPACITY)
    var next_step_saturation := clamp( \
            NEXT_STEP_COLOR.s * step_config.indicator_saturation_ratio, \
            0.0, \
            1.0)
    var next_step_value := clamp( \
            NEXT_STEP_COLOR.v * step_config.indicator_value_ratio, \
            0.0, \
            1.0)
    var next_step_color := \
            Color.from_hsv( \
                    NEXT_STEP_COLOR.h, \
                    next_step_saturation, \
                    next_step_value, \
                    NEXT_STEP_COLOR.a) if \
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
                current_center, \
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
        heartbeat_radius_progress = Utils.ease_by_name( \
                heartbeat_radius_progress, \
                "ease_out_weak")
        heartbeat_radius_progress = sin(heartbeat_radius_progress * PI)
        
        var heartbeat_radius: float = lerp( \
                heartbeat_radius_min, \
                heartbeat_radius_max, \
                heartbeat_radius_progress)
        
        radius = heartbeat_radius
        # We removed the heartbeat label-size change, in favor of instead
        # having the label position shiver.
        label_scale = 1.0
#        label_scale = lerp( \
#                1.0, \
#                step_config.heartbeat_radius_ratio, \
#                heartbeat_radius_progress)
        
    else:
        radius = RADIUS
        label_scale = 1.0
    
    if is_multiplier_active:
        # Draw cooldown progress (circle center / pie slice).
        DrawUtils.draw_pie_slice( \
                self, \
                current_center, \
                radius, \
                1.0 - cooldown_ratio, \
                cooldown_color, \
                SECTOR_ARC_LENGTH)
    else:
        draw_circle( \
                current_center, \
                radius, \
                cooldown_color)
    
    if is_multiplier_active:
        # Draw step progress (circle border).
        if is_multiplier_maxed:
            var next_step_stroke_width := NEXT_STEP_STROKE_WIDTH_END
            DrawUtils.draw_circle_outline( \
                    self, \
                    current_center, \
                    radius, \
                    next_step_color, \
                    next_step_stroke_width, \
                    SECTOR_ARC_LENGTH)
        else:
            var start_angle := -PI / 2.0
            var end_angle := start_angle + 2.0 * PI * next_step_tween_ratio
            var next_step_stroke_width: float = lerp( \
                    NEXT_STEP_STROKE_WIDTH_START, \
                    NEXT_STEP_STROKE_WIDTH_END, \
                    next_step_tween_ratio)
            DrawUtils.draw_arc( \
                    self, \
                    current_center, \
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
            shiver_center - \
            Constants.MAIN_FONT_NORMAL \
                    .get_string_size(multiplier_text) / 2.0 - \
            LABEL_SCALE * label_scale * label_scale + \
            LABEL_OFFSET * label_scale * label_scale
