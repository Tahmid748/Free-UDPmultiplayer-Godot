extends InteractionArea

var pressed := false
var platform_tween : Tween
@onready var platform_object: StaticBody2D = $"../platform"

func interaction_execution(_body) -> bool:
	pressed = !pressed
	if pressed:
		$button_anim.play("pressed")
		platform(true)
	else:
		platform(false)
		$button_anim.play_backwards("pressed")
	
	return true

func platform(up : bool):
	if platform_tween: platform_tween.kill()
	platform_tween = create_tween()
	
	var y_value = 462 if up else 576
	platform_tween.tween_property(platform_object,"position:y", y_value, 3.0)
