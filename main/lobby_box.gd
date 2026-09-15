extends HBoxContainer

@onready var ui: CanvasLayer = $"../.."
@export var starting_level : String

func _on_start_game_pressed() -> void:
	print("starting game...")
	rpc("hide_ui")
	call_deferred("change_level")

func change_level():
	%level.new_level(starting_level)

@rpc("any_peer", "call_local")
func hide_ui():
	Settings.current_level_path = starting_level
	ui.hide()
