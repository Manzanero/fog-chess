class_name Cell
extends Node3D


var piece: Piece = null :
	get:
		if not weakref(piece).get_ref():  # if queued free
			return null
		return piece
		
var material: StandardMaterial3D


var in_sight = false


var center: Vector3 :
	get:
		return position + Vector3(0.5, 0, 0.5)


var color: Color :
	set(value):
		color = value
		material.albedo_color = value

func _ready():
	if $WhiteCell.is_visible():
		material = $WhiteCell/cube.material_override
	if $BlackCell.is_visible():
		material = $BlackCell/cube.material_override
