extends InteractionlessArea

@onready var spike_anim: AnimationPlayer = $"../spike_anim"

func interaction_execution(player) -> void:
	if player is Player:
		pass
