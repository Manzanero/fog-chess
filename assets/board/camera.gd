class_name Camera
extends Marker3D


@export var init_rot_x: float = -60
@export var init_rot_y: float = 0
@export var init_zoom: float = 40

@export var min_rot_x: float = -89
@export var max_rot_x: float = 0
@export var rot_x_speed: float = 0.005
@export var rot_y_speed: float = 0.005


signal rotation_changed


var is_rotate: bool
var offset_move: Vector2


@onready var camera = $Camera3D
@onready var reset_button := %ResetButton as Button


func _ready():
	reset_button.pressed.connect(reset)
	
	reset()
	
	
func reset():
	rotation.x = deg_to_rad(init_rot_x)
	rotation.y = deg_to_rad(init_rot_y)
	camera.transform.origin.z = init_zoom
	
	emit_signal("rotation_changed")


func _process(delta):
	is_rotate = Input.is_action_pressed("right_click")

	if is_rotate:
		var new_rot = rotation + Vector3(-offset_move.y * rot_y_speed, offset_move.x * rot_x_speed, 0)
		new_rot.x = clamp(new_rot.x, deg_to_rad(min_rot_x), deg_to_rad(max_rot_x))
		rotation = new_rot
		
		emit_signal("rotation_changed")

	offset_move = Vector2.ZERO


func _input(event):
	if event is InputEventMouseMotion:
		offset_move += event.relative
