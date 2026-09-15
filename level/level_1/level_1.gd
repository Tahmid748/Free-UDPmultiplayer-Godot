extends Node2D

@onready var player_holder: Marker2D = $player_holder
@onready var reference_camera: Camera2D = $reference_camera

@onready var snake: AnimatedSprite2D = $bg/snake/Snake
var eye_open := false

func _ready() -> void:
	print("level ready")
	
	InitiateLevel.player_holder = $player_holder
	InitiateLevel.reference_camera = $reference_camera
	InitiateLevel.prepare_level()


func _on_beginning_music_finished() -> void:
	await get_tree().create_timer(3.0).timeout
	$beginning_music_looped.play()


func _on_beginning_music_looped_finished() -> void:
	await get_tree().create_timer(3.0).timeout
	$beginning_music_looped.play()


func _on_snake_blinking_timeout() -> void:
	$snake_blinking.wait_time = randf_range(2.5 , 5.5)
	eye_open = !eye_open
	
	if eye_open: snake.play("eye_open")
	else: snake.play("eye_close")
