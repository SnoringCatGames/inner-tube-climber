extends Node2D
class_name ScoreMultiplierCooldownIndicator

const MAIN_FONT_NORMAL: Font = \
        preload("res://assets/fonts/main_font_normal.tres")

const COOLDOWN_DURATION_SEC := 4.0

const CORNER_OFFSET := Vector2(72.0, 72.0)

const LABEL_SCALE := Vector2(1.2, 1.2)
const LABEL_OFFSET := Vector2(-1.0, -4.0)
const RADIUS := 18.0
const NEXT_STEP_STROKE_WIDTH := 5.0
const SECTOR_ARC_LENGTH := 4.0
var COOLDOWN_COLOR := Color.from_hsv(0.1583, 0.78, 1.0, 1.0)
var NEXT_STEP_COLOR := Color.from_hsv(0.6083, 0.68, 0.95, 1.0)
var TEXT_COLOR := Color.from_hsv(0.0, 0.0, 1.0, 1.0)
var TEXT_OUTLINE_COLOR := Color.from_hsv(0.0, 0.0, 0.0, 0.7)
const INACTIVE_OPACITY := 0.3

const MULTIPLIER_VALUES_AND_STEP_DURATIONS: Array = [
    {
        multiplier = 1,
        step_duration_sec = 16.0,
    },
    {
        multiplier = 2,
        step_duration_sec = 32.0,
    },
    {
        multiplier = 4,
        step_duration_sec = 64.0,
    },
    {
        multiplier = 8,
        step_duration_sec = 128.0,
    },
    {
        multiplier = 16,
        step_duration_sec = INF,
    },
]

var center := Vector2.INF
var multiplier_label: Label

var is_multiplier_active := false
var cooldown_ratio := 0.0
var next_step_ratio := 0.0
var is_multiplier_maxed := false

var step_index := 0
var step_start_time_sec := -INF
var cooldown_start_time_sec := -INF
var previous_max_height := -INF

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
            step_start_time_sec != -INF and \
            (step_start_time_sec + step_duration_sec <= current_time_sec)
    
    if has_max_height_changed:
        if !is_multiplier_active:
            step_start_time_sec = current_time_sec
        is_multiplier_active = true
        cooldown_start_time_sec = current_time_sec
        has_cooldown_expired = false
        update()
    
    if has_cooldown_expired:
        is_multiplier_active = false
        step_start_time_sec = -INF
        cooldown_start_time_sec = -INF
        step_index = 0
        update()
        
    elif has_step_duration_passed:
        step_index = min( \
                step_index + 1, \
                MULTIPLIER_VALUES_AND_STEP_DURATIONS.size() - 1)
        step_start_time_sec = current_time_sec
        is_multiplier_maxed = \
                step_index == MULTIPLIER_VALUES_AND_STEP_DURATIONS.size() - 1
        update()
    
    cooldown_ratio = \
            (current_time_sec - cooldown_start_time_sec) / \
                    COOLDOWN_DURATION_SEC if \
            is_multiplier_active else \
            0.0
    next_step_ratio = \
            (current_time_sec - step_start_time_sec) / step_duration_sec if \
            is_multiplier_active else \
            0.0
    
    if is_multiplier_active:
        update()

func _draw() -> void:
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
    
    # Draw cooldown progress (circle center / pie slice).
    DrawUtils.draw_pie_slice( \
            self, \
            center, \
            RADIUS, \
            1.0 - cooldown_ratio, \
            cooldown_color, \
            SECTOR_ARC_LENGTH)
    
    # Draw step progress (circle border).
    if is_multiplier_maxed:
        DrawUtils.draw_circle_outline( \
                self, \
                center, \
                RADIUS, \
                next_step_color, \
                NEXT_STEP_STROKE_WIDTH, \
                SECTOR_ARC_LENGTH)
    else:
        var start_angle := -PI / 2.0
        var end_angle := start_angle + 2.0 * PI * next_step_ratio
        DrawUtils.draw_arc( \
                self, \
                center, \
                RADIUS, \
                start_angle, \
                end_angle, \
                next_step_color, \
                NEXT_STEP_STROKE_WIDTH, \
                SECTOR_ARC_LENGTH)
    
    # Draw multiplier label.
    var multiplier_text: String = "x%1d" % \
            MULTIPLIER_VALUES_AND_STEP_DURATIONS[step_index].multiplier
    multiplier_label.text = multiplier_text
    multiplier_label.add_color_override("font_color", text_color)
    multiplier_label.rect_position = \
            center - \
            MAIN_FONT_NORMAL.get_string_size(multiplier_text) / 2.0 - \
            LABEL_SCALE + \
            LABEL_OFFSET
