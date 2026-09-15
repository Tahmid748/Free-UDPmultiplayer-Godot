extends Node
var udp : PacketPeerUDP:
	get():
		return StunRequest.udp

var role : String
var peer_role : String

var keep_alive_timer : Timer = Timer.new()

var self_ip : String
var self_port : int

var force_host := false #used for developers only
var force_client := false

signal connect_to_peer(peer_ip,peer_port)
signal connected_with_peer
signal log_added(log_text)
signal punch_failed

func _ready() -> void:
	connect_to_peer.connect(_on_connect_to_peer)


func _on_connect_to_peer(peer_ip : String, peer_port : int):
	if !udp.is_bound():
		print("error! udp is not bound")
		Global.show_error("There was a problem with connecting, Please make sure multiple instances are not running.", "connection problem")
		return
	
	udp.set_dest_address(peer_ip,peer_port)
	print("set dest address at: ", peer_ip ,":",str(peer_port))
	log_added.emit("set destination address")
	
	var connection := false
	
	for i in range(50):
		print("waiting for peer...")
		log_added.emit("waiting for peer...")
		print("attempt #", str(i))
		
		var packet_message = "ping:" + MultiplayerManager.self_name
		
		udp.put_packet(packet_message.to_utf8_buffer())
		await get_tree().create_timer(0.3).timeout
		
		if udp.get_available_packet_count() > 0:
			var packet = udp.get_packet()
			var parsed_packet = packet.get_string_from_utf8()
			if parsed_packet.begins_with("ping"):
				udp.put_packet(packet_message.to_utf8_buffer()) #put one final ping
				print("connected to peer!")
				
				var parse_name = parsed_packet.split(":")
				MultiplayerManager.peer_name = parse_name[1] #get the peer name
				
				log_added.emit("suscessfully connected with peer.")
				connection = true
				keep_alive_timer.autostart = true
				keep_alive_timer.timeout.connect(_on_alive_timer_timeout)
				break
	
	if !connection:
		punch_failed.emit()
		Global.show_error("Connection Failed, Please try again.", "Connection Faild :(")
		log_added.emit("punch failed...")
		return
	
	var peer_id = int(peer_ip.replace(".","")) + peer_port
	var self_id = int(self_ip.replace(".","")) + self_port
	print("peer id :", peer_id, "\nself id: ", self_id)
	
	decide_on_roles(peer_id,self_id)
	
	print("role assigned with you as: ",role,"\npeer as: ",peer_role)
	var log_text = "roles sucessfully assigned! \nyour role is: " + role
	log_added.emit(log_text)
	
	connected_with_peer.emit()
	if role == "host":
		udp.put_packet("start".to_utf8_buffer())
		EnetWrapper.host_server()
		return
	
	while true:
		print("waiting for host...")
		if udp.get_available_packet_count() > 0:
			var packet = udp.get_packet().get_string_from_utf8()
			if packet.begins_with("start"):
				break
		await get_tree().create_timer(0.3).timeout
	
	print("connecting client over ENet..")
	log_added.emit("connecting to host...")
	
	EnetWrapper.join_server()

func decide_on_roles(peer_id : int,self_id : int):
	if !force_host or !force_client:
		if self_id > peer_id:
			role = "host"
			peer_role = "client"
		else:
			role = "client"
			peer_role = "host"
	
	if force_host:
		role = "host"
		peer_role = "client"
	if force_client:
		role = "client"
		peer_role = "host"
	
	if force_client and force_host: Global.show_error("Error! both force are enabled, make sure that only one is enabled at a time.", "forcing issue.")

func _on_alive_timer_timeout():
	udp.put_packet("keep alive packet".to_utf8_buffer())
