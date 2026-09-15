extends PanelContainer

@onready var player_name: Label = $VBoxContainer/player_name
@onready var player_sprite: AnimatedSprite2D = $player_sprite
@onready var name_input: LineEdit = $"../connect_to_peer/VBoxContainer/name_input"
@onready var color_button: Button = $VBoxContainer/MarginContainer2/color_button
@onready var color_picker: ColorPicker = $"../ColorPicker"

func _ready() -> void:
	await get_tree().physics_frame
	player_name.text = name_input.text

func _process(_delta: float) -> void:
	player_name.text = name_input.text
	
	MultiplayerManager.self_color = color_picker.color
	player_sprite.material.set_shader_parameter("new_color", MultiplayerManager.self_color)


func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		color_button.text = "confirm"
		color_picker.show()
	else:
		color_button.text = "select color"
		color_picker.hide()
