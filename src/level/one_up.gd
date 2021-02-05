extends Node2D
class_name OneUp

func _on_Area2D_body_entered(body: Node):
    assert(body is TuberPlayer)
    Global.level.add_life()
    # FIXME: Replace this with a better sound
    Audio.play_sound(Sound.TIER_COMPLETE_FINAL)
    queue_free()
