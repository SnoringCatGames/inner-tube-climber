extends Reference
class_name EffectsAnimator

const JUMP_EFFECT_ANIMATION_RESOURCE_PATH := \
        "res://src/player/effects_animations/jump_effect_animation.tscn"

var player
var level

func _init( \
        player, \
        level) -> void:
    self.player = player
    self.level = level

func play(effect: int) -> void:
    var path: String
    match effect:
        EffectAnimation.JUMP:
            path = JUMP_EFFECT_ANIMATION_RESOURCE_PATH
        _:
            Utils.error()
    
    var position: Vector2 = \
            player.position + \
            Vector2(0.0, \
                    Constants.PLAYER_HALF_HEIGHT_DEFAULT * \
                            Constants.PLAYER_SIZE_MULTIPLIER)
    var scale := Vector2(player.surface_state.horizontal_facing_sign, 1)
#    var scale := Vector2( \
#            Constants.PLAYER_SIZE_MULTIPLIER * \
#                    player.surface_state.horizontal_facing_sign, \
#            Constants.PLAYER_SIZE_MULTIPLIER)
    
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

func _on_animation_finished(effect_animator: Node2D) -> void:
    level.remove_child(effect_animator)
    effect_animator.queue_free()
