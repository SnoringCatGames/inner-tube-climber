extends Node2D
class_name PlayerAnimator

const UNFLIPPED_HORIZONTAL_SCALE := Vector2(1,1)
const FLIPPED_HORIZONTAL_SCALE := Vector2(-1,1)

var animation_player: AnimationPlayer

func _ready() -> void:
    var animation_players: Array = \
            Utils.get_children_by_type(self, AnimationPlayer)
    assert(animation_players.size() == 1)
    animation_player = animation_players[0]

func _play_animation( \
        name: String, \
        playback_rate: float = 1) -> bool:
    var is_current_animatior := animation_player.current_animation == name
    var is_playing := animation_player.is_playing()
    var is_changing_direction := \
            (animation_player.get_playing_speed() < 0) != (playback_rate < 0)
    
    var animation_was_not_playing := !is_current_animatior or !is_playing
    var animation_was_playing_in_wrong_direction := \
            is_current_animatior and is_changing_direction
    
    if animation_was_not_playing or \
            animation_was_playing_in_wrong_direction:
        animation_player.play(name, .1, playback_rate)
        return true
    else:
        return false
