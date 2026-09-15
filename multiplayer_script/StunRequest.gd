extends Node

var udp : PacketPeerUDP = PacketPeerUDP.new()

var local_port := 65432

var stunServer_ip = "stun.l.google.com"
var stunServer_port = 19302

signal stun_complete(ip,port)


func initiate_stun_request() -> void:
	udp = PacketPeerUDP.new()
	if udp.is_bound():
		print("Error, UDP is already bound!")
		Global.show_error("There was a problem with getting address, Please make sure multiple instances are not running.", "address issue")
		return
	
	EnetWrapper.local_port = local_port
	
	var bind_status = udp.bind(local_port, "0.0.0.0") #make sure to only use ipv4 address
	if bind_status != OK:
		print("Bind Failed: ", error_string(bind_status))
		return
	
	print("Bound to port at: ", local_port)
	udp.set_dest_address(stunServer_ip,stunServer_port)
	
	var request_package = stun_request_package()
	var requestTransactionID = request_package.transactionID
	var resquestMessage = request_package.requestMessage
	
	udp.put_packet(resquestMessage)
	print("Requesting Stun...")
	
	var timeout = Time.get_ticks_msec() + 5000
	while udp.get_available_packet_count() == 0:
		if Time.get_ticks_msec() > timeout:
			print("stun failed...")
			Global.show_error("error: cloudn't get stun response","stun failed!")
			return
		else:
			await get_tree().create_timer(0.1).timeout
	
	print("response found!")
	
	var responseMessage = udp.get_packet()
	var responseType = responseMessage.decode_u16(0)
	
	var responseTransactionID = responseMessage.slice(8,20)
	
	if responseType != 0x0101 or responseTransactionID != requestTransactionID:
		print("recieved invalid STUN binding response!")
		Global.show_error("invalid STUN response!", "stun failed")
		return
	
	var responseAddress = parse_stun_response(responseMessage.slice(24))
	
	print("STUN was sucessful!")
	print("Public IP Address: ", responseAddress.address)
	print("Public port: ", responseAddress.port)
	
	stun_complete.emit(responseAddress.address,responseAddress.port)

func stun_request_package() -> Dictionary:
	var transactionID = PackedByteArray()
	for n in 12:
		transactionID.append(randi_range(0,255))
	
	var buffer = PackedByteArray()
	buffer.resize(20)
	
	var message = StreamPeerBuffer.new()
	message.data_array = buffer
	message.big_endian = true
	
	message.put_u64(0x0001000000000000)
	message.put_data(transactionID)
	
	
	return {
		"requestMessage" : message.data_array,
		"transactionID" : transactionID
	}



func parse_stun_response(attributes: PackedByteArray) -> Dictionary:
	var streamBuffer = StreamPeerBuffer.new()
	streamBuffer.data_array = attributes
	streamBuffer.big_endian = true
	
	var address_type = streamBuffer.get_u16()
	var discovered_port = streamBuffer.get_u16()
	var discoverd_address = ""
	
	if address_type == 0x01:
		var address = []
		for n in 4:
			address.push_back(streamBuffer.get_u8())
		discoverd_address = ".".join(address)
	
	return {
		"address" : discoverd_address,
		"port" : discovered_port
	}
