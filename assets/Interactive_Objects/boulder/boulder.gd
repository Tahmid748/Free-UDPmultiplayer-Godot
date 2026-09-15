extends RigidBody2D


var speed : float = 5.0
var start := true
var acceleration := 0.2

@export var current_level_path : String #the current level path the boulder is at

func _physics_process(delta: float) -> void:
	if start:
		angular_velocity = lerp(angular_velocity, speed , delta * acceleration)
	else:
		angular_velocity = lerp(angular_velocity, 0.0 , delta * acceleration)


func _input(event: InputEvent) -> void:
	if event.is_action("enter"):
		start = true


func _on_speed_up_timeout() -> void:
	speed = 80.0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.restart_level.emit(current_level_path)
