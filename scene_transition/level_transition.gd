class_name SceneTransition
extends Area2D

@export var next_level_path : String
var player_entered := 0

signal next_level

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	next_level.connect(_on_next_level)
	
	player_entered = 0


func _on_body_entered(body : Node2D):
	if body.is_in_group("player_body"):
		player_entered += 1
		body.process_mode = Node.PROCESS_MODE_DISABLED
		body.hide()
		print("player entered: " , player_entered)
		next_level.emit()


func _on_next_level():
	if !multiplayer.is_server(): return
	if player_entered == 2:
		player_entered = 0
		get_parent().get_parent().call_deferred("new_level",next_level_path)
		
		update_level_path.rpc()


@rpc("any_peer", "call_local")
func update_level_path() -> void:
	Settings.current_level_path = next_level_path
