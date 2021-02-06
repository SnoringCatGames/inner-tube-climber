extends Node2D
class_name OneUp

func _on_Area2D_body_entered(body: Node):
    assert(body is TuberPlayer)
    Global.level.add_life()
    Audio.play_sound(Sound.ACHIEVEMENT)
    queue_free()
