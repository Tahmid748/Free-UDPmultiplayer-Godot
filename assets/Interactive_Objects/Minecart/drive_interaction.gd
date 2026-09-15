extends InteractionArea

@onready var minecart: Minecart = $".."
var on_minecart := false

var player_body : CharacterBody2D

@onready var driver_name: Label = $"../driver_name"
@onready var driving_player_sprite: Sprite2D = $"../driving_player_sprite"
@onready var jumper_name: Label = $"../jumper_name"
@onready var jumping_player_sprite: Sprite2D = $"../jumping_player_sprite"

func interaction_execution(body) -> bool:
	if body is CharacterBody2D:
		if minecart.driving_in_use: return false
		if !on_minecart:
			on_minecart = true
			interaction_label.text = "[E] Exit"
			
			minecart.control_player = body
			player_body = body
			body.on_minecart = true
			
			minecart.can_drive = true
			minecart.configure_action.rpc(true, true)
			minecart.prepare_minecart.rpc(true, true, body.self_name, body.self_color)
			
			body.hide()
			
		else:
			on_minecart = false
			interaction_label.text = "[E] Enter"
			
			minecart.control_player = null
			player_body = null
			body.on_minecart = false
			
			minecart.can_drive = false
			minecart.configure_action.rpc(false, true)
			minecart.prepare_minecart.rpc(false, true)
			
			body.show()
			
	return true

func _process(delta: float) -> void:
	if player_body:
		player_body.global_position = self.global_position
