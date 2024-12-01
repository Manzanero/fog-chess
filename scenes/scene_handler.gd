extends Node


@onready var main_menu := $CanvasLayer as CanvasLayer
@onready var current_scene := $CurrentScene as Node


#var characters = 'ABCDFGHIJKLMNPQRSTUVWXYZ23456789'
var characters = '0123456789'


func generate_world_name():
	var word := "" 
	var n_char = len(characters)
	for i in range(4):
		word += characters[randi()% n_char]
	Data.world_name = "fog_chess__" + word


func _ready():
	%LocalGameButton.pressed.connect(local_game)
	%HostGameButton.pressed.connect(host_game)
	%JoinGameButton.pressed.connect(join_game)
	%CodeJoinGameButton.pressed.connect(code_join_game)
	generate_world_name()


func local_game():
	Data.is_online = false
	Data.is_host = true
	main_menu.queue_free()
	var stage = load("res://assets/board/board.tscn").instantiate()
	current_scene.add_child(stage)


func host_game():
	Data.is_online = true
	Data.is_host = true
	
	var email = "guest@magno.default"
	var password = "password"
	await request_authentication(email, password)
	await connect_to_server()
	await join_world()
	
	main_menu.queue_free()
	var stage = load("res://assets/board/board.tscn").instantiate()
	current_scene.add_child(stage)


func join_game():
	Data.is_online = true
	Data.is_host = false
	%HBoxContainer.visible = false
	%Code.visible = true
	

func code_join_game():
	var email = "guest@magno.default"
	var password = "password"
	
	if %CodeJoinGameInput.text.length() != 4 or not %CodeJoinGameInput.text.is_valid_int():
		%Error.text = "Invalid code"
		return
	
	Data.world_name = "fog_chess__" + %CodeJoinGameInput.text
	await request_authentication(email, password)
	await connect_to_server()
	var joined = await join_world()
	if not joined:
		%Error.text = "Invalid code"
		return
	
	main_menu.queue_free()
	var stage = load("res://assets/board/board.tscn").instantiate()
	current_scene.add_child(stage)


func request_authentication(email, password):
	print("authenticating user %s" % email)
	
	var result: int = await Server.authenticate_async(email, password)
	if result == OK:
		print("authenticated user %s" % email)
	else:
		print("Cannot authenticate user %s" % email)


func connect_to_server():
	print("connecting to server")
	
	var result: int = await Server.connect_to_server_async()
	if result == OK:
		print("connected user to server")
	elif result == ERR_CANT_CONNECT:
		print("Cannot connect user to server")


func join_world():
	print("joining to server")
	var world_name = Data.world_name
	return await Server.join_world_async(Data.is_host, world_name)
	
	print("joined to server")
