extends PlayerAnimator
class_name TuberAnimator

const FACES_RIGHT_BY_DEFAULT := true

const RUN_NAME := "Run"
const RUN_PLAYBACK_RATE := 1.7

const JUMP_NAME := "Jump"
const JUMP_PLAYBACK_RATE := 1.0

const FALL_NAME := "Fall"
const FALL_PLAYBACK_RATE := 1.0

const STAND_NAME := "Stand"
const STAND_PLAYBACK_RATE := 1.0

func _play_animation( \
        name: String, \
        playback_rate: float = 1) -> bool:
    _show_sprite(name)
    return ._play_animation(name, playback_rate)

func _show_sprite(animation_name: String) -> void:
    # Hide the other sprites.
    var sprites := [
        $Run,
        $Stand,
        $Jump,
        $Fall,
    ]
    for sprite in sprites:
        sprite.visible = false
    
    # Show the current sprite.
    match animation_name:
        "Run":
            $Run.visible = true
        "Stand":
            $Stand.visible = true
        "Jump":
            $Jump.visible = true
        "Fall":
            $Fall.visible = true
        _:
            Utils.error()

func face_left() -> void:
    var scale := \
            PlayerAnimator.FLIPPED_HORIZONTAL_SCALE if \
            FACES_RIGHT_BY_DEFAULT else \
            PlayerAnimator.UNFLIPPED_HORIZONTAL_SCALE
    set_scale(scale)

func face_right() -> void:
    var scale := \
            PlayerAnimator.UNFLIPPED_HORIZONTAL_SCALE if \
            FACES_RIGHT_BY_DEFAULT else \
            PlayerAnimator.FLIPPED_HORIZONTAL_SCALE
    set_scale(scale)

func run() -> void:
    _play_animation( \
            RUN_NAME, \
            RUN_PLAYBACK_RATE)

func jump_rise() -> void:
    _play_animation( \
            JUMP_NAME, \
            JUMP_PLAYBACK_RATE)

func jump_fall() -> void:
    _play_animation( \
            FALL_NAME, \
            FALL_PLAYBACK_RATE)

func stand() -> void:
    _play_animation( \
            STAND_NAME, \
            STAND_PLAYBACK_RATE)
