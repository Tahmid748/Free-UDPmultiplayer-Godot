extends Node

@onready var key_holder: LineEdit = $CanvasLayer/UI/address/VBoxContainer/GridContainer/key_holder
@onready var name_input: LineEdit = $CanvasLayer/UI/connect_to_peer/VBoxContainer/name_input

var encryption_key = "PeerAddressEncryptionKeyVeryCool"
var peer_key : String

var use_local := true

var names: Array[String] = [
	"Proto","Hunter","Chrono","Alice","Brown","Nelson","Dick","Hairy","Moon","Flame","Edirgo","Ego","Bastard","Shadow","Fire","Dark","Golden","Emrald",
	"Flame","Silver","Jackson","Sol","Sun","Moon","Astro","Valor","Arc","Mega","Sophia","Wilson","Hilbert","Nickle","Penny","Moist","Bastion","Steve","Alex","Mice","Dragon",
	"Phobia", "Kiwi", "Hinata", "Tokyo", "Raspiration", "Fortunate", "Man", "Griddy", "Boy","Soap","Shampoo","Dollar","Weed", "Diddy", "Gooner", "Newton", "Einsteinn", "AntiMatter",
	"Slayer"
]

func _ready() -> void:
	name_input.text = generate_name()
	
	if use_local:
		Global.show_error("Use local is enabled. This is for testing purposes only." , "warning!")
		var random_port = randi_range(65300 , 65433)
		print("local port set at ", random_port)
		EnetWrapper.local_port = random_port
		StunRequest.udp.bind(random_port)
		
		_on_stun_completed("127.0.0.1", random_port)
		return
	
	StunRequest.initiate_stun_request()
	StunRequest.stun_complete.connect(_on_stun_completed)

func _on_stun_completed(stun_ip,stun_port) -> void:
	print("STUN completed, encrypting address...")
	UdpClient.self_ip = stun_ip
	UdpClient.self_port = stun_port
	
	#encrypt the address
	var external_address = stun_ip + ":" + str(stun_port)
	peer_key = encrypt_address(external_address)
	print("sucessfully encrypted address: ", peer_key)
	
	key_holder.text = peer_key


func generate_name() -> String:
	var rand_num = randi_range(1,6)
	names.shuffle()
	
	var rand = randi_range(0,names.size() - 1)
	var rand2 = randi_range(0,names.size() - 1)
	
	var first_name = names[rand]
	var last_name = names[rand2]
	
	var final_name : String
	match rand_num:
		1: #use a "_" between names
			final_name = first_name + "_" + last_name
		2: #add a number for name
			var random = randi_range(1,1000)
			final_name = first_name + last_name + str(random)
		3:#get a fully random name
			for i in range(3):
				var name_bits = []
				
				for n in range(0,names[i].length(),3):
					name_bits.append(names[i].substr(n,3))
				
				var random = randi_range(0,name_bits.size() - 1)
				final_name += name_bits[random]
			
			var chance = randi_range(1,2)
			if chance == 1:
				var name_num = randi_range(1,100)
				final_name += str(name_num)
			
		4:#get a normal name
			final_name = first_name + last_name
		5:#add xx to name
			final_name = "xx" + first_name + last_name + "xx"
		6:#add 3 names
			var third_name = names[randi_range(0,names.size() - 1)]
			var parts = [first_name,last_name,third_name]
			parts.shuffle()
			final_name = "".join(parts)
			
			var chance = randi_range(1,2)
			if chance == 1:
				var name_num = randi_range(1,100)
				final_name += str(name_num)
	
	return final_name

func encrypt_address(address : String) -> String:
	var padded_address = pkcs7_pad(address.to_utf8_buffer())
	var aes = AESContext.new()
	aes.start(AESContext.MODE_ECB_ENCRYPT, encryption_key.to_utf8_buffer())
	var encrypted_address = aes.update(padded_address)
	
	aes.finish()
	
	var encode_address = encrypted_address.hex_encode()
	
	return encode_address

func decrypt_address(address : String) -> String:
	var decoded_address = address.hex_decode()
	
	var aes = AESContext.new()
	aes.start(AESContext.MODE_ECB_DECRYPT, encryption_key.to_utf8_buffer())
	var decrypted_address = aes.update(decoded_address)
	aes.finish()
	
	return decrypted_address.get_string_from_utf8()


func pkcs7_pad(data: PackedByteArray, block_size: int = 16) -> PackedByteArray:
	var pad_len = block_size - (data.size() % block_size)
	if pad_len == 0:
		pad_len = block_size
	for i in range(pad_len):
		data.append(pad_len) # pad_len repeated
	return data

func pkcs7_unpad(data: PackedByteArray) -> PackedByteArray:
	if data.size() == 0:
		return data
	var pad_len = data[-1]
	return data.slice(0, data.size() - pad_len)

func _on_copy_key_pressed() -> void:
	if peer_key:
		DisplayServer.clipboard_set(peer_key)
		_display_copied(key_holder)


func _display_copied(label : LineEdit) -> void: #using meta data to store the original text so if you spam copy it won't screw up
	if !label.has_meta("original_text"):
		label.set_meta("original_text",label.text)
	label.secret = false
	
	label.text = "Copied!"
	await get_tree().create_timer(0.5).timeout
	label.secret = true
	
	if label.has_meta("original_text"):
		label.text = label.get_meta("original_text")
		label.remove_meta("original_text")


#developer exclusive
func _on_force_host_toggled(toggled_on: bool) -> void:
	Global.show_error("make sure to check the opposite for the peers, your role will be forced to be host", "warning: force host is on")
	UdpClient.force_host = true if toggled_on else false

func _on_force_client_toggled(toggled_on: bool) -> void:
	Global.show_error("make sure to check the opposite for the peers, your role will be forced to be client", "warning: force host is on")
	UdpClient.force_client = true if toggled_on else false


func _on_generate_name_pressed() -> void:
	name_input.text = generate_name()
