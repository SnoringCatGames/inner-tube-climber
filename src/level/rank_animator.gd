tool
extends Control
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
const FRAME_COUNT := 10
const STEP := 0.05
const INTERVAL := 3.6
const SPARKLE_POST_SHINE_DELAY := 0.2
const BLANK_FRAME_START_INDEX := 0
const BLANK_FRAME_COUNT := 1
const BLANK_STEP_MULTIPLIER := 1
const SHINE_FRAME_START_INDEX := 1
const SHINE_FRAME_COUNT := 6
const SHINE_STEP_MULTIPLIER := 2
const SPARKLE_FRAME_START_INDEX := 7
const SPARKLE_FRAME_COUNT := 3
const SPARKLE_EXTRA_STEPS_ON_LAST_FRAME := 2
const SPARKLE_STEP_MULTIPLIER := 1

export var rank := Rank.UNRANKED setget _set_rank,_get_rank
export var is_small := true setget _set_is_small,_get_is_small
export var includes_random_delay := true setget \
        _set_includes_random_delay,_get_includes_random_delay

var _timeout_id: int

func _ready() -> void:
    for rank in [Rank.GOLD, Rank.SILVER, Rank.BRONZE]:
        for is_small in [true, false]:
            var animation_name := _get_animation_name(rank, is_small)
            var texture := _get_texture(rank, is_small)
            
            var sprite := Sprite.new()
            sprite.name = animation_name
            sprite.texture = texture
            sprite.hframes = FRAME_COUNT
            $Control/Node2D.add_child(sprite)
            
            var animation := Animation.new()
            animation.loop = true
            animation.step = STEP
            animation.length = INTERVAL
            $Control/Node2D/AnimationPlayer.add_animation( \
                    animation_name, \
                    animation)
            
            var track_index := animation.add_track(Animation.TYPE_VALUE)
            animation.track_set_path( \
                    track_index, \
                    animation_name + ":frame")
            animation.track_set_interpolation_type( \
                    track_index, \
                    Animation.INTERPOLATION_NEAREST)
            
            var latest_time := 0.0
            
            # Plain.
            for index in range(BLANK_FRAME_COUNT):
                animation.track_insert_key( \
                        track_index, \
                        latest_time, \
                        BLANK_FRAME_START_INDEX + index)
                latest_time += STEP * BLANK_STEP_MULTIPLIER
            
            # Shine.
            for index in range(SHINE_FRAME_COUNT):
                animation.track_insert_key( \
                        track_index, \
                        latest_time, \
                        SHINE_FRAME_START_INDEX + index)
                latest_time += STEP * SHINE_STEP_MULTIPLIER
            
            # Plain.
            animation.track_insert_key( \
                    track_index, \
                    latest_time, \
                    BLANK_FRAME_START_INDEX)
            
            assert(SPARKLE_POST_SHINE_DELAY > STEP * SHINE_STEP_MULTIPLIER)
            
            latest_time += \
                    SPARKLE_POST_SHINE_DELAY - (STEP * SHINE_STEP_MULTIPLIER)
            
            # Sparkle.
            for index in range(SPARKLE_FRAME_COUNT):
                animation.track_insert_key( \
                        track_index, \
                        latest_time, \
                        SPARKLE_FRAME_START_INDEX + index)
                latest_time += STEP * SPARKLE_STEP_MULTIPLIER
            for index in range(SPARKLE_FRAME_COUNT - 1):
                animation.track_insert_key( \
                        track_index, \
                        latest_time, \
                        SPARKLE_FRAME_START_INDEX + \
                            SPARKLE_FRAME_COUNT - \
                            1 - \
                            index)
                latest_time += STEP * SPARKLE_STEP_MULTIPLIER
            
            latest_time += \
                    STEP * \
                    SPARKLE_STEP_MULTIPLIER * \
                    SPARKLE_EXTRA_STEPS_ON_LAST_FRAME
            
            # Plain.
            animation.track_insert_key( \
                    track_index, \
                    latest_time, \
                    BLANK_FRAME_START_INDEX)
            
            assert(latest_time <= INTERVAL)

func _update() -> void:
    var size := SMALL_SIZE if is_small else LARGE_SIZE
    $Control.rect_position = -size / 2.0
    $Control.rect_size = size
    $Control/Node2D.position = size / 2.0
    
    _hide_sprites()
    
    if rank == Rank.UNRANKED:
        return
    
    var animation_name := _get_animation_name(rank, is_small)
    get_node('Control/Node2D/' + animation_name).visible = true
    $Control/Node2D/AnimationPlayer.stop()
    
    var delay_sec = \
            randf() * INTERVAL if \
            includes_random_delay else \
            0.0
    Time.clear_timeout(_timeout_id)
    _timeout_id = Time.set_timeout(funcref(self, "_play"), delay_sec)

func _play() -> void:
    var animation_name := _get_animation_name(rank, is_small)
    $Control/Node2D/AnimationPlayer.play(animation_name)

func _hide_sprites() -> void:
    for rank in [Rank.GOLD, Rank.SILVER, Rank.BRONZE]:
        for is_small in [true, false]:
            var animation_name := _get_animation_name(rank, is_small)
            get_node('Control/Node2D/' + animation_name).visible = false

func _get_texture( \
        rank: int, \
        is_small: bool) -> Texture:
    match rank:
        Rank.GOLD:
            if is_small:
                return GOLD_TEXTURE_SMALL
            else:
                return GOLD_TEXTURE_LARGE
        Rank.SILVER:
            if is_small:
                return SILVER_TEXTURE_SMALL
            else:
                return SILVER_TEXTURE_LARGE
        Rank.BRONZE:
            if is_small:
                return BRONZE_TEXTURE_SMALL
            else:
                return BRONZE_TEXTURE_LARGE
        _:
            Utils.error()
            return null

func _get_animation_name( \
        rank: int, \
        is_small: bool) -> String:
    var prefix := \
            "Small" if \
            is_small else \
            "Large"
    
    var suffix: String
    match rank:
        Rank.GOLD:
            suffix = "Gold"
        Rank.SILVER:
            suffix = "Silver"
        Rank.BRONZE:
            suffix = "Bronze"
        _:
            Utils.error()
    
    return prefix + suffix

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

func _set_includes_random_delay(value: bool) -> void:
    includes_random_delay = value
    _update()

func _get_includes_random_delay() -> bool:
    return includes_random_delay
