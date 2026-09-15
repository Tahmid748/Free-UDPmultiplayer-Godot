extends InteractionArea

func interaction_execution(body) -> bool:
	if body is CharacterBody2D:
		if body.in_water:
			return false
	
	self.queue_free()
	
	return true
