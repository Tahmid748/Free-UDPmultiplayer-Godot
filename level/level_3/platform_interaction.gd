extends Area2D

@onready var platform_anim: AnimationPlayer = $"../platform_anim"

var started := false

func _on_body_entered(body: Node2D) -> void:
	if body is Minecart:
		if started: return
		body.jump_velocity = 1000
		body.forward_speed = 20
		raise_platform.rpc()

func _on_body_exited(body: Node2D) -> void:
	if body is Minecart: #return the jump vel to original
		body.jump_velocity = 550
		body.forward_speed = 150


@rpc("any_peer", "call_local")
func raise_platform():
	platform_anim.play("platform_up")
	started = true
