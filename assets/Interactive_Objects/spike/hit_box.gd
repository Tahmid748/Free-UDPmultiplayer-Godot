extends InteractionlessArea

func interaction_execution(player) -> void:
	if player is Player:
		if player.is_multiplayer_authority():
			Global.restart_level.emit(get_parent().current_level_path)
