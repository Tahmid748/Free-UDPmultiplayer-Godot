extends Area2D

@export var push_force : float = 280
@onready var piston_anim: AnimatedSprite2D = $piston_anim

enum push_dir{ LEFT , RIGHT }
@export var push : push_dir = push_dir.RIGHT

func _on_body_entered(body: Node2D) -> void:
	if body is Minecart:
		rpc("push_minecart", body)
		push_minecart(body)


@rpc("any_peer")
func push_minecart(minecart):
	if !minecart is Minecart: return
	
	minecart.linear_velocity.y = -1600
	
	if push == push_dir.LEFT:
		minecart.apply_impulse(Vector2.LEFT * push_force)
	else:
		minecart.apply_impulse(Vector2.RIGHT * push_force)
	piston_anim.play()
