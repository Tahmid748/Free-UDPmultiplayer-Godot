extends MarginContainer

@onready var main: Node = $"../../.."

@onready var peer_key_input: LineEdit = $VBoxContainer/peer_key_input
@onready var connect_button: Button = $VBoxContainer/MarginContainer/connect

@onready var address: MarginContainer = $"../address"
@onready var connect_to_peer: MarginContainer = $"."
@onready var character_creator: PanelContainer = $"../character_creator"
@onready var color_picker: ColorPicker = $"../ColorPicker"

@onready var waiting_label: Label = $"../waiting"

@onready var start_game_button: Button = $"../lobby_box/PanelContainer/VBoxContainer/MarginContainer/start_game"

@onready var log_text: Label = $"../log"

func _ready() -> void:
	UdpClient.log_added.connect(_on_log_added)
	UdpClient.connected_with_peer.connect(on_peer_connected)
	UdpClient.punch_failed.connect(_on_punch_failed)

func _on_connect_pressed() -> void:
	
	if main.name_input.text == "":
		Global.show_error("Please Input a name.", "No name found!")
		return
	
	MultiplayerManager.self_name = main.name_input.text
	
	print("Decrypting Address...")
	if peer_key_input.text.is_valid_hex_number():
		var decrypted_address = main.decrypt_address(peer_key_input.text)
		var peer_address = decrypted_address.split(":")
	
		var peer_ip = peer_address[0]
		var peer_port = int(peer_address[1])
		
		EnetWrapper.peer_address = peer_ip
		EnetWrapper.peer_port = peer_port
		
		print("Sucessfully decrypted address")
		print("Peer IP: ", peer_ip)
		print("Peer Port:", peer_port)
		
		print("connecting with peer...")
		log_text.text = "connecting to peer..."
		
		connect_button.disabled = true
		
		UdpClient.connect_to_peer.emit(peer_ip,peer_port)
	else:
		Global.show_error("Please input valid address" , "error!")

func on_peer_connected() -> void:
	address.hide()
	connect_to_peer.hide()
	character_creator.hide()
	color_picker.hide()
	
	waiting_label.show()
	
	if UdpClient.role == "client":
		start_game_button.text = "waiting for host..."
		start_game_button.disabled = true
		

func _on_punch_failed() -> void:
	connect_button.disabled = false

func _on_log_added(string) -> void:
	log_text.text = string
