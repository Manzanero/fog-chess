extends Node3D

@onready var body_pivot := $BodyPivot as Marker3D
@onready var body := $BodyPivot/Body/Sprite3D as Sprite3D
@onready var camera := %Camera as Camera


func _ready():
	camera.rotation_changed.connect(face_camera)
	face_camera()


func _process(delta):
	pass


func face_camera():
	body_pivot.rotation.y = camera.rotation.y
	body.position = camera.rotation.x / PI * Vector3.FORWARD
