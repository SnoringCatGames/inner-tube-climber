extends Node2D
class_name SnowScreenHandler

const SNOW_SCREEN_RESOURCE_PATH := "res://src/level/snow_screen.tscn"

const SNOW_DENSITY_MULTIPLIER_PRE_STUCK := 1.0
var SNOW_DENSITY_MULTIPLIER_POST_STUCK: float = \
        LevelConfig.BASE_TIER.snow_density_multiplier

const TRANSITION_DURATION_SEC := CameraController.ZOOM_ANIMATION_DURATION_SEC

var snow_screen: SnowScreen
var snow_density_multiplier_tween: Tween
var snow_density_multiplier := SNOW_DENSITY_MULTIPLIER_POST_STUCK

func _enter_tree() -> void:
    snow_density_multiplier_tween = Tween.new()
    add_child(snow_density_multiplier_tween)
    
    snow_screen = Utils.add_scene( \
            Global.canvas_layers.game_screen_layer, \
            SNOW_SCREEN_RESOURCE_PATH, \
            true, \
            true)

func destroy() -> void:
    if snow_screen != null:
        remove_child(snow_screen)
        snow_screen.queue_free()
        snow_screen = null

func update_windiness(windiness: Vector2) -> void:
    snow_screen.windiness = windiness

func set_start_state() -> void:
    _interpolate_snow_density_multiplier(SNOW_DENSITY_MULTIPLIER_PRE_STUCK)

func set_post_stuck_state(animates: bool) -> void:
    if animates:
        # TODO: Revisit this if there ever is a need to tween this.
#        snow_density_multiplier_tween.stop(self)
#        snow_density_multiplier_tween.interpolate_method( \
#                self, \
#                "_interpolate_snow_density_multiplier", \
#                SNOW_DENSITY_MULTIPLIER_PRE_STUCK, \
#                SNOW_DENSITY_MULTIPLIER_POST_STUCK, \
#                Constants.TRANSITION_TO_POST_STUCK_DURATION_SEC, \
#                Tween.TRANS_QUAD, \
#                Tween.EASE_IN_OUT)
#        snow_density_multiplier_tween.start()
        _interpolate_snow_density_multiplier( \
                SNOW_DENSITY_MULTIPLIER_POST_STUCK)
    else:
        _interpolate_snow_density_multiplier( \
                SNOW_DENSITY_MULTIPLIER_POST_STUCK)

func update_for_current_tier( \
        level_id: String, \
        tier_id: String) -> void:
    var is_base_tier := tier_id == "0"
    var level_config: Dictionary = LevelConfig.get_level_config(level_id)
    var tier_config: Dictionary = LevelConfig.get_tier_config(tier_id)
    
    var previous_snow_density_multiplier: float
    var next_snow_density_multiplier: float
    if is_base_tier:
        previous_snow_density_multiplier = SNOW_DENSITY_MULTIPLIER_PRE_STUCK
        next_snow_density_multiplier = SNOW_DENSITY_MULTIPLIER_PRE_STUCK
    else:
        previous_snow_density_multiplier = snow_density_multiplier
        next_snow_density_multiplier = LevelConfig.get_value( \
                level_id, \
                tier_id, \
                "snow_density_multiplier")
    
    # TODO: Revisit this if there ever is a need to tween this.
#    snow_density_multiplier_tween.stop(self)
#    snow_density_multiplier_tween.interpolate_method( \
#            self, \
#            "_interpolate_snow_density_multiplier", \
#            previous_snow_density_multiplier, \
#            next_snow_density_multiplier, \
#            TRANSITION_DURATION_SEC, \
#            Tween.TRANS_QUAD, \
#            Tween.EASE_IN_OUT)
#    snow_density_multiplier_tween.start()
    _interpolate_snow_density_multiplier(next_snow_density_multiplier)

func _interpolate_snow_density_multiplier(value: float) -> void:
    snow_density_multiplier = value
    snow_screen.snow_density_multiplier = snow_density_multiplier
