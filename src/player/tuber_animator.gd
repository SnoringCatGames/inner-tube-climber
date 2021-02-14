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

const STUCK_NAME := "Stuck"
const STUCK_PLAYBACK_RATE := 1.0

var jump_scale_multiplier := Vector2.ONE setget \
        _set_jump_scale_multiplier,_get_jump_scale_multiplier
var bounce_scale_multiplier := Vector2.ONE setget \
        _set_bounce_scale_multiplier,_get_bounce_scale_multiplier

var jump_offset := Vector2.ONE setget _set_jump_offset,_get_jump_offset
var bounce_offset := Vector2.ONE setget _set_bounce_offset,_get_bounce_offset

var _scale_x_sign := 1 if FACES_RIGHT_BY_DEFAULT else -1

func _enter_tree() -> void:
    face_right()

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
        $Stuck,
    ]
    for sprite in sprites:
        sprite.visible = false
    
    # Show the current sprite.
    match animation_name:
        RUN_NAME:
            $Run.visible = true
        STAND_NAME:
            $Stand.visible = true
        JUMP_NAME:
            $Jump.visible = true
        FALL_NAME:
            $Fall.visible = true
        STUCK_NAME:
            $Stuck.visible = true
        _:
            Utils.error()

func face_left() -> void:
    _scale_x_sign = \
            -1 if \
            FACES_RIGHT_BY_DEFAULT else \
            1
    _update_scale()

func face_right() -> void:
    _scale_x_sign = \
            1 if \
            FACES_RIGHT_BY_DEFAULT else \
            -1
    _update_scale()

func _update_scale() -> void:
    var scale := Vector2(_scale_x_sign, 1.0)
    scale *= Constants.PLAYER_SIZE_MULTIPLIER
    scale.x *= jump_scale_multiplier.x
    scale.y *= jump_scale_multiplier.y
    scale.x *= bounce_scale_multiplier.x
    scale.y *= bounce_scale_multiplier.y
    self.scale = scale

func _update_offset() -> void:
    self.position = jump_offset + bounce_offset

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

func stuck() -> void:
    _play_animation( \
            STUCK_NAME, \
            STUCK_PLAYBACK_RATE)

func _set_jump_scale_multiplier(value: Vector2) -> void:
    jump_scale_multiplier = value
    _update_scale()

func _get_jump_scale_multiplier() -> Vector2:
    return jump_scale_multiplier

func _set_bounce_scale_multiplier(value: Vector2) -> void:
    bounce_scale_multiplier = value
    _update_scale()

func _get_bounce_scale_multiplier() -> Vector2:
    return bounce_scale_multiplier

func _set_jump_offset(value: Vector2) -> void:
    jump_offset = value
    _update_offset()

func _get_jump_offset() -> Vector2:
    return jump_offset

func _set_bounce_offset(value: Vector2) -> void:
    bounce_offset = value
    _update_offset()

func _get_bounce_offset() -> Vector2:
    return bounce_offset
