extends Node
class_name FogScreenHandler

signal updated

const FOG_SCREEN_RESOURCE_PATH := "res://src/level/fog_screen.tscn"

const PEEP_HOLE_SIZE_PRE_STUCK := Vector2(400.0, 400.0)
const PEEP_HOLE_SIZE_POST_STUCK := Vector2(360.0, 360.0)
const FOG_SCREEN_OPACITY_PRE_STUCK := 1.0
const FOG_SCREEN_OPACITY_POST_STUCK := 1.0
const FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_PRE_STUCK := 0.3
const FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_POST_STUCK := 0.3
const FOG_SCREEN_PRIMARY_COLOR_PRE_STUCK := Color("#ffffff")
const FOG_SCREEN_PRIMARY_COLOR_POST_STUCK := Color("#ffffff")
const FOG_SCREEN_SECONDARY_COLOR_PRE_STUCK := Color("#52c8ff")
const FOG_SCREEN_SECONDARY_COLOR_POST_STUCK := Color("#52c8ff")
const FOG_SCREEN_PRIMARY_COLOR_WEIGHT_POST_STUCK := 1.0
const FOG_SCREEN_SECONDARY_COLOR_WEIGHT_POST_STUCK := 1.0

const TRANSITION_DURATION_SEC := CameraController.ZOOM_ANIMATION_DURATION_SEC

var fog_screen: FogScreen

var peep_hole_size_tween: Tween
var fog_screen_opacity_tween: Tween
var fog_screen_secondary_color_opacity_multiplier_tween: Tween
var fog_screen_primary_color_tween: Tween
var fog_screen_secondary_color_tween: Tween

var peep_hole_size := PEEP_HOLE_SIZE_PRE_STUCK
var fog_screen_opacity := FOG_SCREEN_OPACITY_PRE_STUCK
var fog_screen_secondary_color_opacity_multiplier := \
        FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_PRE_STUCK
var fog_screen_primary_color := FOG_SCREEN_PRIMARY_COLOR_PRE_STUCK
var fog_screen_secondary_color := FOG_SCREEN_PRIMARY_COLOR_PRE_STUCK

func _enter_tree() -> void:
    peep_hole_size_tween = Tween.new()
    add_child(peep_hole_size_tween)
    
    fog_screen_opacity_tween = Tween.new()
    add_child(fog_screen_opacity_tween)
    
    fog_screen_secondary_color_opacity_multiplier_tween = Tween.new()
    add_child(fog_screen_secondary_color_opacity_multiplier_tween)
    
    fog_screen_primary_color_tween = Tween.new()
    add_child(fog_screen_primary_color_tween)
    
    fog_screen_secondary_color_tween = Tween.new()
    add_child(fog_screen_secondary_color_tween)
    
    fog_screen = Utils.add_scene( \
            Global.canvas_layers.game_screen_layer, \
            FOG_SCREEN_RESOURCE_PATH, \
            true, \
            true)

func destroy() -> void:
    if fog_screen != null:
        remove_child(fog_screen)
        fog_screen.queue_free()
        fog_screen = null

func sync_to_player_position(player_position: Vector2) -> void:
    fog_screen.player_position = player_position

func set_start_state() -> void:
    peep_hole_size = PEEP_HOLE_SIZE_PRE_STUCK
    fog_screen_opacity = FOG_SCREEN_OPACITY_PRE_STUCK
    fog_screen_secondary_color_opacity_multiplier = \
            FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_PRE_STUCK
    fog_screen_primary_color = FOG_SCREEN_PRIMARY_COLOR_PRE_STUCK
    fog_screen_secondary_color = FOG_SCREEN_SECONDARY_COLOR_PRE_STUCK
    _update_fog_screen( \
            peep_hole_size, \
            fog_screen_opacity, \
            fog_screen_secondary_color_opacity_multiplier, \
            fog_screen_primary_color, \
            fog_screen_secondary_color)

func set_post_stuck_state(animates: bool) -> void:
    peep_hole_size = PEEP_HOLE_SIZE_POST_STUCK
    fog_screen_opacity = FOG_SCREEN_OPACITY_POST_STUCK
    fog_screen_primary_color = FOG_SCREEN_PRIMARY_COLOR_POST_STUCK
    
    if animates:
        var tween := Tween.new()
        add_child(tween)
        tween.interpolate_method( \
                self, \
                "_interpolate_to_post_stuck_state", \
                0.0, \
                1.0, \
                Constants.TRANSITION_TO_POST_STUCK_DURATION_SEC, \
                Tween.TRANS_QUAD, \
                Tween.EASE_IN_OUT)
        tween.start()
    else:
        _interpolate_to_post_stuck_state(1.0)

func _interpolate_to_post_stuck_state(progress: float) -> void:
    # Update peep hole screen (size and opacity).
    var current_peep_hole_size: Vector2 = lerp( \
            PEEP_HOLE_SIZE_PRE_STUCK, \
            PEEP_HOLE_SIZE_POST_STUCK, \
            progress)
    var current_screen_opacity: float = lerp( \
            FOG_SCREEN_OPACITY_PRE_STUCK, \
            FOG_SCREEN_OPACITY_POST_STUCK, \
            progress)
    var current_screen_secondary_color_opacity_multiplier: float = lerp( \
            FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_PRE_STUCK, \
            FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_POST_STUCK, \
            progress)
    var current_screen_primary_color: Color = lerp( \
            FOG_SCREEN_PRIMARY_COLOR_PRE_STUCK, \
            FOG_SCREEN_PRIMARY_COLOR_POST_STUCK, \
            progress)
    var current_screen_secondary_color: Color = lerp( \
            FOG_SCREEN_SECONDARY_COLOR_PRE_STUCK, \
            FOG_SCREEN_SECONDARY_COLOR_POST_STUCK, \
            progress)
    _update_fog_screen( \
            current_peep_hole_size, \
            current_screen_opacity, \
            current_screen_secondary_color_opacity_multiplier, \
            current_screen_primary_color, \
            current_screen_secondary_color)

func update_for_current_tier( \
        level_id: String, \
        tier_id: String) -> void:
    var is_base_tier := tier_id == "0"
    var level_config: Dictionary = LevelConfig.LEVELS[level_id]
    var tier_config: Dictionary = LevelConfig.TIERS[tier_id]
    
    var previous_peep_hole_size: Vector2
    var next_peep_hole_size: Vector2
    var previous_fog_screen_opacity: float
    var next_fog_screen_opacity: float
    var previous_fog_screen_secondary_color_opacity_multiplier: float
    var next_fog_screen_secondary_color_opacity_multiplier: float
    var previous_fog_screen_primary_color: Color
    var next_fog_screen_primary_color: Color
    var previous_fog_screen_secondary_color: Color
    var next_fog_screen_secondary_color: Color
    if is_base_tier:
        previous_peep_hole_size = Vector2(1024.0, 1024.0)
        next_peep_hole_size = PEEP_HOLE_SIZE_PRE_STUCK
        previous_fog_screen_opacity = 0.0
        next_fog_screen_opacity = FOG_SCREEN_OPACITY_PRE_STUCK
        previous_fog_screen_secondary_color_opacity_multiplier = 0.0
        next_fog_screen_secondary_color_opacity_multiplier = \
                FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_PRE_STUCK
        previous_fog_screen_primary_color = FOG_SCREEN_PRIMARY_COLOR_PRE_STUCK
        next_fog_screen_primary_color = FOG_SCREEN_PRIMARY_COLOR_PRE_STUCK
        previous_fog_screen_secondary_color = \
                FOG_SCREEN_SECONDARY_COLOR_PRE_STUCK
        next_fog_screen_secondary_color = FOG_SCREEN_SECONDARY_COLOR_PRE_STUCK
    else:
        previous_peep_hole_size = peep_hole_size
        next_peep_hole_size = \
            PEEP_HOLE_SIZE_POST_STUCK * \
            level_config.peep_hole_size_multiplier * \
            tier_config.peep_hole_size_multiplier
        previous_fog_screen_opacity = fog_screen_opacity
        next_fog_screen_opacity = \
                FOG_SCREEN_OPACITY_POST_STUCK * \
                level_config.fog_screen_opacity_multiplier * \
                tier_config.fog_screen_opacity_multiplier
        previous_fog_screen_secondary_color_opacity_multiplier = \
                fog_screen_secondary_color_opacity_multiplier
        next_fog_screen_secondary_color_opacity_multiplier = \
                FOG_SCREEN_SECONDARY_COLOR_OPACITY_MULTIPLIER_POST_STUCK * \
                level_config \
                        .fog_screen_secondary_color_opacity_multiplier_multiplier * \
                tier_config \
                        .fog_screen_secondary_color_opacity_multiplier_multiplier
        previous_fog_screen_primary_color = fog_screen_primary_color
        previous_fog_screen_secondary_color = fog_screen_secondary_color
        next_fog_screen_primary_color = Utils.mix_colors([ \
                    FOG_SCREEN_PRIMARY_COLOR_POST_STUCK,
                    level_config.fog_screen_primary_color,
                    tier_config.fog_screen_primary_color,
                ], [\
                    FOG_SCREEN_PRIMARY_COLOR_WEIGHT_POST_STUCK,
                    level_config.fog_screen_primary_color_weight,
                    tier_config.fog_screen_primary_color_weight,
                ])
        next_fog_screen_secondary_color = Utils.mix_colors([ \
                    FOG_SCREEN_SECONDARY_COLOR_POST_STUCK,
                    level_config.fog_screen_secondary_color,
                    tier_config.fog_screen_secondary_color,
                ], [\
                    FOG_SCREEN_SECONDARY_COLOR_WEIGHT_POST_STUCK,
                    level_config.fog_screen_secondary_color_weight,
                    tier_config.fog_screen_secondary_color_weight,
                ])
    
    next_peep_hole_size.x = max(next_peep_hole_size.x, 0.0)
    next_peep_hole_size.y = max(next_peep_hole_size.y, 0.0)
    next_fog_screen_opacity = clamp( \
            next_fog_screen_opacity, \
            0.0, \
            1.0)
    next_fog_screen_secondary_color_opacity_multiplier = clamp( \
            next_fog_screen_secondary_color_opacity_multiplier, \
            0.0, \
            1.0 / next_fog_screen_opacity)
    
    peep_hole_size_tween.stop(self)
    peep_hole_size_tween.interpolate_method( \
            self, \
            "_interpolate_peep_hole_size", \
            previous_peep_hole_size, \
            next_peep_hole_size, \
            TRANSITION_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT)
    peep_hole_size_tween.start()
    
    fog_screen_opacity_tween.stop(self)
    fog_screen_opacity_tween.interpolate_method( \
            self, \
            "_interpolate_fog_screen_opacity", \
            previous_fog_screen_opacity, \
            next_fog_screen_opacity, \
            TRANSITION_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT)
    fog_screen_opacity_tween.start()
    
    fog_screen_secondary_color_opacity_multiplier_tween.stop(self)
    fog_screen_secondary_color_opacity_multiplier_tween.interpolate_method( \
            self, \
            "_interpolate_fog_screen_secondary_color_opacity_multiplier", \
            previous_fog_screen_secondary_color_opacity_multiplier, \
            next_fog_screen_secondary_color_opacity_multiplier, \
            TRANSITION_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT)
    fog_screen_secondary_color_opacity_multiplier_tween.start()
    
    fog_screen_primary_color_tween.stop(self)
    fog_screen_primary_color_tween.interpolate_method( \
            self, \
            "_interpolate_fog_screen_primary_color", \
            previous_fog_screen_primary_color, \
            next_fog_screen_primary_color, \
            TRANSITION_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT)
    fog_screen_primary_color_tween.start()
    
    fog_screen_secondary_color_tween.stop(self)
    fog_screen_secondary_color_tween.interpolate_method( \
            self, \
            "_interpolate_fog_screen_secondary_color", \
            previous_fog_screen_secondary_color, \
            next_fog_screen_secondary_color, \
            TRANSITION_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT)
    fog_screen_secondary_color_tween.start()

func _interpolate_peep_hole_size(size: Vector2) -> void:
    peep_hole_size = size
    _update_fog_screen( \
            peep_hole_size, \
            fog_screen_opacity, \
            fog_screen_secondary_color_opacity_multiplier, \
            fog_screen_primary_color, \
            fog_screen_secondary_color)

func _interpolate_fog_screen_opacity(opacity: float) -> void:
    fog_screen_opacity = opacity
    _update_fog_screen( \
            peep_hole_size, \
            fog_screen_opacity, \
            fog_screen_secondary_color_opacity_multiplier, \
            fog_screen_primary_color, \
            fog_screen_secondary_color)

func _interpolate_fog_screen_secondary_color_opacity_multiplier( \
        opacity: float) -> void:
    fog_screen_secondary_color_opacity_multiplier = opacity
    _update_fog_screen( \
            peep_hole_size, \
            fog_screen_opacity, \
            fog_screen_secondary_color_opacity_multiplier, \
            fog_screen_primary_color, \
            fog_screen_secondary_color)

func _interpolate_fog_screen_primary_color(color: Color) -> void:
    fog_screen_primary_color = color
    _update_fog_screen( \
            peep_hole_size, \
            fog_screen_opacity, \
            fog_screen_secondary_color_opacity_multiplier, \
            fog_screen_primary_color, \
            fog_screen_secondary_color)

func _interpolate_fog_screen_secondary_color(color: Color) -> void:
    fog_screen_secondary_color = color
    _update_fog_screen( \
            peep_hole_size, \
            fog_screen_opacity, \
            fog_screen_secondary_color_opacity_multiplier, \
            fog_screen_primary_color, \
            fog_screen_secondary_color)

func _update_fog_screen( \
        hole_size: Vector2, \
        screen_opacity: float, \
        screen_secondary_color_opacity_multiplier: float, \
        screen_primary_color: Color, \
        screen_secondary_color: Color) -> void:
    var hole_radius := min(hole_size.x, hole_size.y) * 0.5
    fog_screen.hole_radius = hole_radius
    fog_screen.screen_opacity = screen_opacity
    fog_screen.secondary_color_opacity_multiplier = \
            screen_secondary_color_opacity_multiplier
    fog_screen.primary_color = screen_primary_color
    fog_screen.secondary_color = screen_secondary_color
    emit_signal("updated")
