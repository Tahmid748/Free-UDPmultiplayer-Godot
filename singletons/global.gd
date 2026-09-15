extends Node

signal restart_level(level_path : String)
var stop_input : bool = false

func _ready() -> void:
	restart_level.connect(on_restart_level)

func show_error(error_str : String, error_title : String) -> void:
	var popup = AcceptDialog.new()
	popup.dialog_text = error_str
	popup.title = error_title
	add_child(popup)
	popup.popup_centered()


func on_restart_level(level_path : String) -> void:
	# The level node is replicated by Main/level_spawner.  Only the server must
	# replace it; the MultiplayerSpawner then performs the matching replacement
	# on every client.
	if multiplayer.is_server():
		restart(level_path)
	else:
		request_restart.rpc_id(1, level_path)

@rpc("any_peer")
func request_restart(level_path : String) -> void:
	if multiplayer.is_server():
		restart(level_path)

func restart(path : String) -> void:
	get_tree().get_first_node_in_group("level").call_deferred("new_level",path)
