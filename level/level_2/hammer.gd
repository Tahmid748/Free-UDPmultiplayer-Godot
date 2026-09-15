extends Weapon

func _on_area_entered(area : Area2D):
	if area.name == "hit_box":
		var interaction_area = area.get_parent()
		if interaction_area.hit_interaction:
			interaction_area.take_hit()
			$"..".has_weapon = false
			remove_self()
			rpc("remove_self")


@rpc("any_peer")
func remove_self():
	self.queue_free()
