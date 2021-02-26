extends Node2D
class_name TierRatioSign

var text: String setget _set_text,_get_text

var windiness: Vector2 setget _set_windiness

func ignite() -> void:
    $LeftTorch.ignite()
    $RightTorch.ignite()

func _set_text(value: String) -> void:
    $Label.text = value

func _get_text() -> String:
    return $Label.text

func _set_windiness(value: Vector2) -> void:
    $LeftTorch.windiness = value
    $RightTorch.windiness = value

func show_tier_id_sign(tier_id: String) -> void:
    $TierIdSign.text = "Tier " + tier_id
    $TierIdSign.visible = true
