extends Node

var player_holder
var reference_camera
var disable_camera := false

func prepare_level(offline_mode : bool = false):
	if offline_mode: return
	if not multiplayer.is_server():
		return
	
	if not (multiplayer.is_connected("peer_connected", add_player) and multiplayer.is_connected("peer_disconnected", del_player)):
		multiplayer.peer_connected.connect(add_player)
		multiplayer.peer_disconnected.connect(del_player)
	
	for id in multiplayer.get_peers():
		add_player(id)
	
	add_player(1)


func add_player(id : int):
	print("player joined: " , id)
	var player = preload("res://player/player.tscn")
	var new_player = player.instantiate()
	new_player.player_id = id
	new_player.name = str(id)
	
	player_holder.add_child(new_player,true)
	new_player.camera_limit_changed.emit(reference_camera.limit_left,reference_camera.limit_top,reference_camera.limit_right,
										reference_camera.limit_bottom,disable_camera)

func del_player(id : int):
	if not player_holder.has_node(str(id)):
		return
	
	player_holder.get_node(str(id)).queue_free()

func _exit_tree() -> void:
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)
