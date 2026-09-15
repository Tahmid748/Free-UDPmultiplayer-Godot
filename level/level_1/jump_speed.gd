extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_body"):
		body.jump_velocity *= 1.5
		$"../item".play()
		self.queue_free()
