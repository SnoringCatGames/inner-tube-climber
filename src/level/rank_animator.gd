tool extends Control
class_name RankAnimator

const GOLD_TEXTURE_LARGE := \
        preload("res://assets/images/rank-large-gold.png")
const SILVER_TEXTURE_LARGE := \
        preload("res://assets/images/rank-large-silver.png")
const BRONZE_TEXTURE_LARGE := \
        preload("res://assets/images/rank-large-bronze.png")
const GOLD_TEXTURE_SMALL := \
        preload("res://assets/images/rank-small-gold.png")
const SILVER_TEXTURE_SMALL := \
        preload("res://assets/images/rank-small-silver.png")
const BRONZE_TEXTURE_SMALL := \
        preload("res://assets/images/rank-small-bronze.png")

const LARGE_SIZE := Vector2(54.0, 64.0)
const SMALL_SIZE := Vector2(27.0, 32.0)

export var rank := Rank.UNRANKED setget _set_rank,_get_rank
export var is_small := true setget _set_is_small,_get_is_small

func _ready() -> void:
    pass

func _update() -> void:
    var size := SMALL_SIZE if is_small else LARGE_SIZE
    $Control.rect_position = -size / 2.0
    $Control.rect_size = size
    $Control/Node2D.position = size / 2.0
    
    if rank == Rank.UNRANKED:
        $Control.visible = false
        return
    
    var animation := Animation.new()
    var track_index := animation.add_track(Animation.TYPE_VALUE)
    $Control/Node2D/AnimationPlayer.add_animation("Shine", animation)
    # FIXME: LEFT OFF HERE:

func _set_rank(value: int) -> void:
    rank = value
    _update()

func _get_rank() -> int:
    return rank

func _set_is_small(value: bool) -> void:
    is_small = value
    _update()

func _get_is_small() -> bool:
    return is_small
