tool
extends Node2D
class_name TorchFlame

const WINDINESS_UPWARD_THRESHOLD := 0.5
const BURST_SCALE := 1.4
const BURST_DURATION_SEC := 0.5

var is_lit := false
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

func ignite(is_bursting: bool) -> void:
    _update_lit(true, is_bursting)
    if !is_bursting:
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
        is_bursting: bool) -> void:
    self.is_lit = is_lit
    _set_directional_flame_visibile()
    if is_bursting:
        $Burst.visible = false
        $Burst.playing = false
    else:
        $Burst.frame = 0
        $Burst.visible = is_lit
        $Burst.playing = is_lit

func _set_windiness(value: Vector2) -> void:
    if windiness != value:
        windiness = value
        _set_directional_flame_visibile()

func _set_directional_flame_visibile() -> void:
    $PersistentWrapper/Up.visible = false
    $PersistentWrapper/Left.visible = false
    $PersistentWrapper/Right.visible = false
    $PersistentWrapper/Up.playing = false
    $PersistentWrapper/Left.playing = false
    $PersistentWrapper/Right.playing = false
    if is_lit:
        if windiness.x < -WINDINESS_UPWARD_THRESHOLD:
            $PersistentWrapper/Left.visible = true
            $PersistentWrapper/Left.playing = true
        elif windiness.x > WINDINESS_UPWARD_THRESHOLD:
            $PersistentWrapper/Right.visible = true
            $PersistentWrapper/Right.playing = true
        else:
            $PersistentWrapper/Up.visible = true
            $PersistentWrapper/Up.playing = true

func _on_burst_finished() -> void:
    $Burst.frame = 0
    $Burst.visible = false
