extends CanvasLayer

@export var current_level_path : String

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		visible = !visible
		Global.stop_input = visible

func _on_resume_pressed() -> void:
	self.hide()
	Global.stop_input = visible

func _on_restart_pressed() -> void:
	Global.restart_level.emit(current_level_path)
	
	self.hide()
	Global.stop_input = visible
