extends Node


@onready var main_menu := $CanvasLayer as CanvasLayer
@onready var current_scene := $CurrentScene as Node


func _ready():
	%LocalGameButton.pressed.connect(local_game)
	%HostGameButton.pressed.connect(host_game)
	%JoinGameButton.pressed.connect(join_game)


func local_game():
	Data.is_host = true
	main_menu.queue_free()
	var stage = load("res://assets/board/board.tscn").instantiate()
	current_scene.add_child(stage)


func host_game():
	Data.is_online = true
	Data.is_host = true
	main_menu.queue_free()
	var stage = load("res://assets/board/board.tscn").instantiate()
	current_scene.add_child(stage)


func join_game():
	Data.is_online = true
	main_menu.queue_free()
	var stage = load("res://assets/board/board.tscn").instantiate()
	current_scene.add_child(stage)
