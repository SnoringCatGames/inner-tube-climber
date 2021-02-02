extends ColorRect
class_name FadeTransition

signal fade_complete

var tween: Tween
var duration := 0.3
var is_transitioning := false

func _ready() -> void:
    tween = Tween.new()
    add_child(tween)
    Global.connect( \
            "display_resized", \
            self, \
            "_on_display_resized")
    _on_display_resized()
    
    _set_cutoff(0)

func _on_display_resized() -> void:
    rect_size = get_viewport().size

func fade() -> void:
    tween.stop_all()
    tween.interpolate_method( \
            self, \
            "_set_cutoff", \
            1.0, \
            0.0, \
            duration / 2.0, \
            Tween.TRANS_SINE, \
            Tween.EASE_IN)
    tween.interpolate_method( \
            self, \
            "_set_cutoff", \
            0.0, \
            1.0, \
            duration / 2.0, \
            Tween.TRANS_SINE, \
            Tween.EASE_OUT, \
            duration / 2.0)
    tween.start()
    is_transitioning = true
    Time.set_timeout(funcref(self, "_on_tween_complete"), duration)

func _set_cutoff(value: float) -> void:
    material.set_shader_param( \
            "cutoff", \
            value)

func _on_tween_complete() -> void:
    is_transitioning = false
    emit_signal("fade_complete")
