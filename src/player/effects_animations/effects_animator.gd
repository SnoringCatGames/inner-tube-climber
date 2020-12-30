extends Reference
class_name EffectsAnimator

const JUMP_SIDEWAYS_EFFECT_ANIMATION_RESOURCE_PATH := \
        "res://src/player/effects_animations/jump_sideways_effect_animation.tscn"
const JUMP_VERTICAL_EFFECT_ANIMATION_RESOURCE_PATH := \
        "res://src/player/effects_animations/jump_vertical_effect_animation.tscn"
const LAND_EFFECT_ANIMATION_RESOURCE_PATH := \
        "res://src/player/effects_animations/land_effect_animation.tscn"
const WALK_EFFECT_ANIMATION_RESOURCE_PATH := \
        "res://src/player/effects_animations/walk_effect_animation.tscn"
const WALL_BOUNCE_EFFECT_ANIMATION_RESOURCE_PATH := \
        "res://src/player/effects_animations/wall_bounce_effect_animation.tscn"
const CEILING_HIT_EFFECT_ANIMATION_RESOURCE_PATH := \
        "res://src/player/effects_animations/ceiling_hit_effect_animation.tscn"

var player
var level

# Dictionary<Node2D, Node2D>
var effects := {}

func _init( \
        player, \
        level) -> void:
    self.player = player
    self.level = level

func destroy() -> void:
    for effect in effects.keys():
        _on_animation_finished(effect)

func play( \
        effect: int, \
        horizontal_sign := 0) -> void:
    var path: String
    match effect:
        EffectAnimation.JUMP_SIDEWAYS:
            path = JUMP_SIDEWAYS_EFFECT_ANIMATION_RESOURCE_PATH
        EffectAnimation.JUMP_VERTICAL:
            path = JUMP_VERTICAL_EFFECT_ANIMATION_RESOURCE_PATH
        EffectAnimation.LAND:
            path = LAND_EFFECT_ANIMATION_RESOURCE_PATH
        EffectAnimation.WALK:
            path = WALK_EFFECT_ANIMATION_RESOURCE_PATH
        EffectAnimation.WALL_BOUNCE:
            path = WALL_BOUNCE_EFFECT_ANIMATION_RESOURCE_PATH
        EffectAnimation.CEILING_HIT:
            path = CEILING_HIT_EFFECT_ANIMATION_RESOURCE_PATH
        _:
            Utils.error()
    
    var scale_x_sign: int = \
            horizontal_sign if \
            horizontal_sign != 0 else \
            pow(-1, randi() % 2)
    
    var position: Vector2 = \
            player.position + \
            Vector2(0.0, \
                    Constants.PLAYER_HALF_HEIGHT_DEFAULT * \
                            Constants.PLAYER_SIZE_MULTIPLIER)
    var scale := Vector2(scale_x_sign, 1)
#    scale *= Constants.PLAYER_SIZE_MULTIPLIER
    
    var effect_animator: Node2D = Utils.add_scene( \
            level, \
            path, \
            true, \
            true)
    effect_animator.position = position
    effect_animator.scale = scale
    
    var sprite: AnimatedSprite = effect_animator.get_node("AnimatedSprite")
    sprite.frame = 0
    sprite.connect( \
            "animation_finished", \
            self, \
            "_on_animation_finished", \
            [effect_animator])
    sprite.play()
    
    effects[effect_animator] = effect_animator

func _on_animation_finished(effect_animator: Node2D) -> void:
    level.remove_child(effect_animator)
    effect_animator.queue_free()
    effects.erase(effect_animator)
