extends InteractionArea

var health := 100
var destroyed := false

func interaction_execution(_body) -> bool:
	if destroyed: return true
	
	health -= 50
	interaction_label.text = "[" + str(health) + "%]"
	
	if health <= 0:
		destroyed = true
		remove_self()
	
	return true

func remove_self():
	await get_tree().create_timer(0.2).timeout
	self.queue_free()
