extends PanelContainer

@onready var waiting_txt: Label = $"../../waiting"
@onready var text_box: LineEdit = $VBoxContainer/text_box
@onready var log_text: Label = $"../../log"
@onready var lobby_box: HBoxContainer = $".."
@onready var body_text: Label = $VBoxContainer/ScrollContainer/body_text

@onready var player_1_name: Label = $"../PanelContainer/VBoxContainer/MarginContainer2/VBoxContainer/player_1"
@onready var player_2_name: Label = $"../PanelContainer/VBoxContainer/MarginContainer2/VBoxContainer/player_2"

func _ready() -> void:
	EnetWrapper.connection_sucessful.connect(_on_enet_connection)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		send_message(text_box.text)

func _on_enet_connection() -> void:
	lobby_box.show()
	waiting_txt.hide()
	log_text.hide()
	
	player_1_name.text = "Player 1: " + MultiplayerManager.self_name
	player_2_name.text = "Player 2: " + MultiplayerManager.peer_name 

func _on_send_message_pressed() -> void:
	send_message(text_box.text)

func send_message(msg: String):
	if msg == "": return
	send_message_rpc(msg)
	text_box.text = ""


func send_message_rpc(msg : String) -> void:
	body_text.text += "you: " + msg + "\n"
	rpc("display_message", msg)

@rpc("any_peer")
func display_message(msg : String):
	body_text.text += MultiplayerManager.peer_name + ": " + msg + "\n"
