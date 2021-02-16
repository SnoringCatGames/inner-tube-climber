tool
extends Node2D
class_name TorchFlame

const WINDINESS_MULTIPLIER := Vector2(0.6, 0.3)
const MAX_OUTER_FLAME_SPEED_PIXELS_PER_SEC := 140.0
const INITIAL_VELOCITY_DEFAULT_PIXELS_PER_SEC := Vector2(0.0, -106.99)
const INNER_FLAME_TO_OUTER_FLAME_SPEED_RATIO := 0.655
const SPARKS_TO_OUTER_FLAME_SPEED_RATIO := 0.5
const SMOKE_TO_OUTER_FLAME_SPEED_RATIO := 1.0

const BURST_SCALE := 1.6
const BURST_DURATION_SEC := 0.5

var windiness := Vector2.ZERO setget _set_windiness
var burst_tween: Tween

func _ready() -> void:
    burst_tween = Tween.new()
    add_child(burst_tween)
    
    $Burst.connect("animation_finished", self, "_on_burst_finished")
    
    if Engine.editor_hint:
        ignite(true)
    else:
        snuff()

func snuff() -> void:
    _update_lit(false, false)

func ignite(is_new_life: bool) -> void:
    _update_lit(true, is_new_life)
    if !is_new_life:
        var flare_up_duration_sec := BURST_DURATION_SEC * 0.67
        var flare_down_duration_sec := \
                BURST_DURATION_SEC - flare_up_duration_sec
        burst_tween.interpolate_property( \
                $PersistentWrapper, \
                "scale", \
                Vector2.ZERO, \
                Vector2(BURST_SCALE, BURST_SCALE), \
                flare_up_duration_sec, \
                Tween.TRANS_QUART, \
                Tween.EASE_IN_OUT)
        burst_tween.interpolate_property( \
                $PersistentWrapper, \
                "scale", \
                Vector2(BURST_SCALE, BURST_SCALE), \
                Vector2.ONE, \
                flare_down_duration_sec, \
                Tween.TRANS_QUAD, \
                Tween.EASE_IN_OUT, \
                flare_up_duration_sec)
        burst_tween.start()

func _update_lit( \
        is_lit: bool, \
        is_new_life: bool) -> void:
    $PersistentWrapper/VerticalPersistent.visible = is_lit
    $PersistentWrapper/VerticalPersistent.playing = is_lit
    if is_new_life:
        $Burst.visible = false
        $Burst.playing = false
    else:
        $Burst.frame = 0
        $Burst.visible = is_lit
        $Burst.playing = is_lit

func _set_windiness(value: Vector2) -> void:
    if windiness != value:
        windiness = value
        # FIXME: Update which direction of persistent is shown, based on wind direction.

func _on_burst_finished() -> void:
    $Burst.frame = 0
    $Burst.visible = false
