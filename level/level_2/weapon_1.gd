extends InteractionArea

@onready var weapon_reference: Area2D = $"../weapon_reference"
@onready var player_holder: Marker2D = $"../player_holder"

func interaction_execution(body) -> bool:
	if body is CharacterBody2D:
		if body.has_weapon:
			return false
	
	var player_body = body
	if !body is CharacterBody2D:
		for player in player_holder.get_children():
			if !player.is_multiplayer_authority():
				player_body = player
	
	var weapon = weapon_reference.duplicate()
	weapon.process_mode = Node.PROCESS_MODE_INHERIT
	weapon.show()
	player_body.add_child(weapon)
	player_body.has_weapon = true
	
	self.hide()
	return true
