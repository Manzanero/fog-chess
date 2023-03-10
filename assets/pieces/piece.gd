class_name Piece
extends Node3D


enum PieceType {TOWER, KNIGHT, BISHOP, QUEEN, KING, PAWN}
enum PieceColor {WHITE, BLACK}


@export var type: PieceType
@export var color: PieceColor


signal dragged
signal dropped


var mouse_over := false
var is_dragged := false
var is_first_move := true
var sight_lines := []

var piece_capturable_en_passant :Piece = null

@onready var draggable := $StaticBody3D as StaticBody3D
@onready var body_pivot := $BodyPivot as Marker3D
@onready var body := $BodyPivot/Body/Sprite3D as Sprite3D
@onready var camera := %Camera as Camera


func _ready():
	draggable.mouse_entered.connect(func(): mouse_over = true)
	draggable.mouse_exited.connect(func(): mouse_over = false)
	
	camera.rotation_changed.connect(face_camera)

	get_lines_by_type(type)
	face_camera()


func _physics_process(_delta):
	if mouse_over and Input.is_action_just_pressed("left_click"):
		emit_signal("dragged")
		is_dragged = true
		
	elif is_dragged and Input.is_action_just_released("left_click"):
		emit_signal("dropped")
		is_dragged = false


func face_camera():
	body_pivot.rotation.y = camera.rotation.y
	body.position = camera.rotation.x / PI * Vector3.FORWARD


func get_lines_by_type(piece_type: PieceType):
	if color == PieceColor.WHITE:
		sight_lines = white_lines_by_type[piece_type]
	else:
		sight_lines = black_lines_by_type[piece_type]


const white_lines_by_type = {
	PieceType.TOWER: [
		[Vector3i(0, 0, -1), Vector3i(0, 0, -2), Vector3i(0, 0, -3), Vector3i(0, 0, -4), Vector3i(0, 0, -5), Vector3i(0, 0, -6), Vector3i(0, 0, -7)],
		[Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(3, 0, 0), Vector3i(4, 0, 0), Vector3i(5, 0, 0), Vector3i(6, 0, 0), Vector3i(7, 0, 0)],
		[Vector3i(0, 0, 1), Vector3i(0, 0, 2), Vector3i(0, 0, 3), Vector3i(0, 0, 4), Vector3i(0, 0, 5), Vector3i(0, 0, 6), Vector3i(0, 0, 7)],
		[Vector3i(-1, 0, 0), Vector3i(-2, 0, 0), Vector3i(-3, 0, 0), Vector3i(-4, 0, 0), Vector3i(-5, 0, 0), Vector3i(-6, 0, 0), Vector3i(-7, 0, 0)],
	],
	PieceType.KNIGHT: [
		[Vector3i(-1, 0, -2)],
		[Vector3i(1, 0, -2)],
		[Vector3i(2, 0, -1)],
		[Vector3i(2, 0, 1)],
		[Vector3i(1, 0, 2)],
		[Vector3i(-1, 0, 2)],
		[Vector3i(-2, 0, 1)],
		[Vector3i(-2, 0, -1)],
	],
	PieceType.BISHOP: [
		[Vector3i(1, 0, -1), Vector3i(2, 0, -2), Vector3i(3, 0, -3), Vector3i(4, 0, -4), Vector3i(5, 0, -5), Vector3i(6, 0, -6), Vector3i(7, 0, -7)],
		[Vector3i(1, 0, 1), Vector3i(2, 0, 2), Vector3i(3, 0, 3), Vector3i(4, 0, 4), Vector3i(5, 0, 5), Vector3i(6, 0, 6), Vector3i(7, 0, 7)],
		[Vector3i(-1, 0, 1), Vector3i(-2, 0, 2), Vector3i(-3, 0, 3), Vector3i(-4, 0, 4), Vector3i(-5, 0, 5), Vector3i(-6, 0, 6), Vector3i(-7, 0, 7)],
		[Vector3i(-1, 0, -1), Vector3i(-2, 0, -2), Vector3i(-3, 0, -3), Vector3i(-4, 0, -4), Vector3i(-5, 0, -5), Vector3i(-6, 0, -6), Vector3i(-7, 0, -7)],
	],
	PieceType.QUEEN: [
		[Vector3i(0, 0, -1), Vector3i(0, 0, -2), Vector3i(0, 0, -3), Vector3i(0, 0, -4), Vector3i(0, 0, -5), Vector3i(0, 0, -6), Vector3i(0, 0, -7)],
		[Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(3, 0, 0), Vector3i(4, 0, 0), Vector3i(5, 0, 0), Vector3i(6, 0, 0), Vector3i(7, 0, 0)],
		[Vector3i(0, 0, 1), Vector3i(0, 0, 2), Vector3i(0, 0, 3), Vector3i(0, 0, 4), Vector3i(0, 0, 5), Vector3i(0, 0, 6), Vector3i(0, 0, 7)],
		[Vector3i(-1, 0, 0), Vector3i(-2, 0, 0), Vector3i(-3, 0, 0), Vector3i(-4, 0, 0), Vector3i(-5, 0, 0), Vector3i(-6, 0, 0), Vector3i(-7, 0, 0)],
		[Vector3i(1, 0, -1), Vector3i(2, 0, -2), Vector3i(3, 0, -3), Vector3i(4, 0, -4), Vector3i(5, 0, -5), Vector3i(6, 0, -6), Vector3i(7, 0, -7)],
		[Vector3i(1, 0, 1), Vector3i(2, 0, 2), Vector3i(3, 0, 3), Vector3i(4, 0, 4), Vector3i(5, 0, 5), Vector3i(6, 0, 6), Vector3i(7, 0, 7)],
		[Vector3i(-1, 0, 1), Vector3i(-2, 0, 2), Vector3i(-3, 0, 3), Vector3i(-4, 0, 4), Vector3i(-5, 0, 5), Vector3i(-6, 0, 6), Vector3i(-7, 0, 7)],
		[Vector3i(-1, 0, -1), Vector3i(-2, 0, -2), Vector3i(-3, 0, -3), Vector3i(-4, 0, -4), Vector3i(-5, 0, -5), Vector3i(-6, 0, -6), Vector3i(-7, 0, -7)],
	],
	PieceType.KING: [
		[Vector3i(0, 0, -1)],
		[Vector3i(1, 0, 0), Vector3i(2, 0, 0)],
		[Vector3i(0, 0, 1)],
		[Vector3i(-1, 0, 0), Vector3i(-2, 0, 0)],
		[Vector3i(1, 0, -1)],
		[Vector3i(1, 0, 1)],
		[Vector3i(-1, 0, 1)],
		[Vector3i(-1, 0, -1)],
	],
	PieceType.PAWN: [
		[Vector3i(0, 0, -1), Vector3i(0, 0, -2)],
		[Vector3i(1, 0, 0)],
		[Vector3i(-1, 0, 0)],
		[Vector3i(1, 0, -1)],
		[Vector3i(-1, 0, -1)],
	],
}  


const black_lines_by_type = {
	PieceType.TOWER: [
		[Vector3i(0, 0, -1), Vector3i(0, 0, -2), Vector3i(0, 0, -3), Vector3i(0, 0, -4), Vector3i(0, 0, -5), Vector3i(0, 0, -6), Vector3i(0, 0, -7)],
		[Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(3, 0, 0), Vector3i(4, 0, 0), Vector3i(5, 0, 0), Vector3i(6, 0, 0), Vector3i(7, 0, 0)],
		[Vector3i(0, 0, 1), Vector3i(0, 0, 2), Vector3i(0, 0, 3), Vector3i(0, 0, 4), Vector3i(0, 0, 5), Vector3i(0, 0, 6), Vector3i(0, 0, 7)],
		[Vector3i(-1, 0, 0), Vector3i(-2, 0, 0), Vector3i(-3, 0, 0), Vector3i(-4, 0, 0), Vector3i(-5, 0, 0), Vector3i(-6, 0, 0), Vector3i(-7, 0, 0)],
	],
	PieceType.KNIGHT: [
		[Vector3i(-1, 0, -2)],
		[Vector3i(1, 0, -2)],
		[Vector3i(2, 0, -1)],
		[Vector3i(2, 0, 1)],
		[Vector3i(1, 0, 2)],
		[Vector3i(-1, 0, 2)],
		[Vector3i(-2, 0, 1)],
		[Vector3i(-2, 0, -1)],
	],
	PieceType.BISHOP: [
		[Vector3i(1, 0, -1), Vector3i(2, 0, -2), Vector3i(3, 0, -3), Vector3i(4, 0, -4), Vector3i(5, 0, -5), Vector3i(6, 0, -6), Vector3i(7, 0, -7)],
		[Vector3i(1, 0, 1), Vector3i(2, 0, 2), Vector3i(3, 0, 3), Vector3i(4, 0, 4), Vector3i(5, 0, 5), Vector3i(6, 0, 6), Vector3i(7, 0, 7)],
		[Vector3i(-1, 0, 1), Vector3i(-2, 0, 2), Vector3i(-3, 0, 3), Vector3i(-4, 0, 4), Vector3i(-5, 0, 5), Vector3i(-6, 0, 6), Vector3i(-7, 0, 7)],
		[Vector3i(-1, 0, -1), Vector3i(-2, 0, -2), Vector3i(-3, 0, -3), Vector3i(-4, 0, -4), Vector3i(-5, 0, -5), Vector3i(-6, 0, -6), Vector3i(-7, 0, -7)],
	],
	PieceType.QUEEN: [
		[Vector3i(0, 0, -1), Vector3i(0, 0, -2), Vector3i(0, 0, -3), Vector3i(0, 0, -4), Vector3i(0, 0, -5), Vector3i(0, 0, -6), Vector3i(0, 0, -7)],
		[Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(3, 0, 0), Vector3i(4, 0, 0), Vector3i(5, 0, 0), Vector3i(6, 0, 0), Vector3i(7, 0, 0)],
		[Vector3i(0, 0, 1), Vector3i(0, 0, 2), Vector3i(0, 0, 3), Vector3i(0, 0, 4), Vector3i(0, 0, 5), Vector3i(0, 0, 6), Vector3i(0, 0, 7)],
		[Vector3i(-1, 0, 0), Vector3i(-2, 0, 0), Vector3i(-3, 0, 0), Vector3i(-4, 0, 0), Vector3i(-5, 0, 0), Vector3i(-6, 0, 0), Vector3i(-7, 0, 0)],
		[Vector3i(1, 0, -1), Vector3i(2, 0, -2), Vector3i(3, 0, -3), Vector3i(4, 0, -4), Vector3i(5, 0, -5), Vector3i(6, 0, -6), Vector3i(7, 0, -7)],
		[Vector3i(1, 0, 1), Vector3i(2, 0, 2), Vector3i(3, 0, 3), Vector3i(4, 0, 4), Vector3i(5, 0, 5), Vector3i(6, 0, 6), Vector3i(7, 0, 7)],
		[Vector3i(-1, 0, 1), Vector3i(-2, 0, 2), Vector3i(-3, 0, 3), Vector3i(-4, 0, 4), Vector3i(-5, 0, 5), Vector3i(-6, 0, 6), Vector3i(-7, 0, 7)],
		[Vector3i(-1, 0, -1), Vector3i(-2, 0, -2), Vector3i(-3, 0, -3), Vector3i(-4, 0, -4), Vector3i(-5, 0, -5), Vector3i(-6, 0, -6), Vector3i(-7, 0, -7)],
	],
	PieceType.KING: [
		[Vector3i(0, 0, -1)],
		[Vector3i(1, 0, 0), Vector3i(2, 0, 0)],
		[Vector3i(0, 0, 1)],
		[Vector3i(-1, 0, 0), Vector3i(-2, 0, 0)],
		[Vector3i(1, 0, -1)],
		[Vector3i(1, 0, 1)],
		[Vector3i(-1, 0, 1)],
		[Vector3i(-1, 0, -1)],
	],
	PieceType.PAWN: [
		[Vector3i(0, 0, 1), Vector3i(0, 0, 2)],
		[Vector3i(1, 0, 0)],
		[Vector3i(-1, 0, 0)],
		[Vector3i(1, 0, 1)],
		[Vector3i(-1, 0, 1)],
	],
}  
