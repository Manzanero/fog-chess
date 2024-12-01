extends Node

const KEY = "defaultkey"
const HOST = "alejmans.dev"
const PORT = 7350
const SCHEMA = "https"


var client : NakamaClient
var session : NakamaSession
var socket : NakamaSocket
var multiplayer_bridge
var match_id

var user_id := "local" :
	get:
		return session.user_id if session else user_id


func _init():
	client = Nakama.create_client(KEY, HOST, PORT, SCHEMA)


func authenticate_async(email, password) -> Error:
	var result := OK
	
	var new_session = await client.authenticate_email_async(email, password) as NakamaSession
	
	if not new_session.is_exception():
		session = new_session
	else:
		result = new_session.get_exception().status_code as Error

	return result


func connect_to_server_async() -> Error:
	socket = Nakama.create_socket_from(client)
	socket.connected.connect(_on_socket_connected)
	socket.closed.connect(_on_socket_closed)
	socket.received_error.connect(_on_socket_error)
	socket.received_match_state.connect(_on_match_state)
	
	var result := await socket.connect_async(session) as NakamaAsyncResult
	if not result.is_exception():
		return OK
	
	return ERR_CANT_CONNECT


func _on_socket_connected():
	print("Socket connected.")


func _on_socket_closed():
	socket = null


func _on_socket_error(err):
	printerr("Socket error %s" % err)
	

func join_world_async(is_host, match_name=null):
	multiplayer_bridge = NakamaMultiplayerBridge.new(socket)
	multiplayer_bridge.match_join_error.connect(_on_match_join_error)
	multiplayer_bridge.match_joined.connect(_on_match_join)
	
	if is_host:
		var result := await socket.create_match_async(match_name) as NakamaRTAPI.Match
		if result.is_exception():
			var exception: NakamaException = result.get_exception()
			printerr("Errror joining the match: %s - %s" % [exception.status_code, exception.message])
			
		match_id = result.match_id
		
	else:
		await multiplayer_bridge.join_named_match(match_name)
		match_id = multiplayer_bridge.match_id
	
		if multiplayer_bridge._users.size() == 1:
			socket.leave_match_async(match_id)
			return false
			
	if multiplayer_bridge._users.size() == 3:
		socket.leave_match_async(match_id)
		return false
	
	return true

func _on_match_join_error(error):
	print ("Unable to join match: ", error.message)


func _on_match_join() -> void:
	print ("Joined match with id: ", multiplayer_bridge.match_id)


func _on_network_peer_connected(peer_id):
	print ("Peer joined match: ", peer_id)


func _on_network_peer_disconnected(peer_id):
	print ("Peer left match: ", peer_id)
	
	
func _process(_delta):	
	if match_id and Input.is_action_just_pressed("right_click"):
		var message = "hello from " + ("host" if Data.is_host else "not host")
		send_message_async(message)


####################
# Operations
####################

enum OpCode {
	MESSAGE,
	JOIN,
	MOVEMENT,
	EN_PASSANT,
	PROMOTE,
	NEXT_TURN,
}


signal join
signal movement(old, new)
signal en_passant(who, whom)
signal promote(who, piece_type)
signal next_turn


func send_message_async(message):
	var payload = {"message": message}
	if socket:
		socket.send_match_state_async(match_id, OpCode.MESSAGE, JSON.stringify(payload))
	
	
func send_join():
	var payload := {}
	if socket:
		socket.send_match_state_async(match_id, OpCode.JOIN, JSON.stringify(payload))


func send_movement_async(old: Vector3i, new: Vector3i):
	var payload := {"old": [old.x, old.z], "new": [new.x, new.z]}
	if socket:
		socket.send_match_state_async(match_id, OpCode.MOVEMENT, JSON.stringify(payload))
	
	
func send_en_passant(who: Vector3i, whom: Vector3i):
	var payload := {"who": [who.x, who.z], "whom": [whom.x, whom.z]}
	if socket:
		socket.send_match_state_async(match_id, OpCode.EN_PASSANT, JSON.stringify(payload))
	
	
func send_promote(who: Vector3i, piece_type: Piece.PieceType):
	var payload := {"who": [who.x, who.z], "piece_type": piece_type}
	if socket:
		socket.send_match_state_async(match_id, OpCode.PROMOTE, JSON.stringify(payload))
	
	
func send_next_turn_async():
	var payload := {}
	if socket:
		socket.send_match_state_async(match_id, OpCode.NEXT_TURN, JSON.stringify(payload))


func _on_match_state(match_state : NakamaRTAPI.MatchData):
	var data = JSON.parse_string(match_state.data)
	print("Match state: %s %s" % [match_state.op_code, data])
	
	match match_state.op_code:
		OpCode.MESSAGE:
			var message = data["message"]
			print(message)
		OpCode.JOIN:
			emit_signal("join")
		OpCode.MOVEMENT:
			var old = data["old"]
			var new = data["new"]
			emit_signal("movement", Vector3i(old[0], 0, old[1]), Vector3i(new[0], 0, new[1]))
		OpCode.EN_PASSANT:
			var who = data["who"]
			var whom = data["whom"]
			emit_signal("en_passant", Vector3i(who[0], 0, who[1]), Vector3i(whom[0], 0, whom[1]))
		OpCode.PROMOTE:
			var who = data["who"]
			emit_signal("promote", Vector3i(who[0], 0, who[1]), data["piece_type"])
		OpCode.NEXT_TURN:
			emit_signal("next_turn")
		_:
			print("Unsupported op code.")
