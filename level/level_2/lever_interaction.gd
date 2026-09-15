extends InteractionArea


func interaction_execution(_body) -> bool:
	$lever_anim.play("pressed")
	$"..".drain_water()
	return true
