extends Area2D

@export var current_level_path : String
@export var body_name : String

@onready var spike_anim: AnimationPlayer = $spike_anim

func _on_body_entered(body: Node2D) -> void:
	if body.name == body_name:
		spike_anim.play("spike_activate")
