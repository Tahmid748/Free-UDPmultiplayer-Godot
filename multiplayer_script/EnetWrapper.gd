extends Node

var peer_address : String
var peer_port : int
var local_port : int

signal connection_sucessful

func host_server():
	print("starting server..")
	if StunRequest.udp.is_bound(): StunRequest.udp.close()
	if UdpClient.udp.is_bound(): UdpClient.udp.close()
	
	var host_peer = ENetMultiplayerPeer.new()
	print("Creating server with port: ", local_port)
	host_peer.create_server(local_port)
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.multiplayer_peer = host_peer
	

func join_server():
	print("joining server")
	if StunRequest.udp.is_bound(): StunRequest.udp.close()
	if UdpClient.udp.is_bound(): UdpClient.udp.close()
	
	var client_peer = ENetMultiplayerPeer.new()
	print("connnecting to peer at ", peer_address, ":",peer_port, " with local port set at ", local_port)
	client_peer.create_client(peer_address,peer_port,0,0,0,local_port)
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.multiplayer_peer = client_peer


func _on_peer_connected(id: int):
	print("peer connected with the id ", id)
	connection_sucessful.emit()

func _on_connected_to_server():
	print("sucessfully connected to enet server!")
	connection_sucessful.emit()
