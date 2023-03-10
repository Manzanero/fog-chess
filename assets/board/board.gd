extends Node3D

signal vision_changed

var mouse_position := Vector3.ZERO
var mouse_cell: Cell = null

var player_is_white := true
var is_white_turn := true
var move_mode := false
var mouse_piece :Piece = null
var previous_position := Vector3.ZERO
var previous_cell: Cell = null

var cells := {}
var white_pieces := []
var black_pieces := []
var white_king
var black_king
var is_end_game := false


@onready var camera := %Camera as Camera
@onready var cells_parent := $Cells as Node3D
@onready var pieces_parent := $Pieces as Node3D


func _ready():
	for cell in cells_parent.get_children():
		cells[Vector3i(cell.position)] = cell
			
	for piece in pieces_parent.get_children():
		piece.dragged.connect(init_move.bind(piece))
		piece.dropped.connect(end_move.bind())
		var piece_position = piece.position
		var piece_cell = get_cell(piece_position)
		piece_cell.piece = piece
		if piece.color == Piece.PieceColor.WHITE:
			white_pieces.append(piece)
			if piece.type == Piece.PieceType.KING:
				white_king = piece
		else:
			black_pieces.append(piece)
			if piece.type == Piece.PieceType.KING:
				black_king = piece

	vision_changed.connect(update_in_sight)
	update_in_sight()
	
	%SwitchButton.pressed.connect(switch_color)
	%ReadyButton.pressed.connect(ready)
	%RetryButton.pressed.connect(reset_game)


func _physics_process(delta):
	process_mouse_position()

	if move_mode:
		process_move(delta)


func process_mouse_position():
	var mouse_pos = get_viewport().get_mouse_position()
	camera.ray.from = camera.camera.project_ray_origin(mouse_pos)
	camera.ray.to = camera.ray.from + camera.camera.project_ray_normal(mouse_pos) * camera.ray_length
	var board_intersect = get_world_3d().direct_space_state.intersect_ray(camera.ray)

	if board_intersect:
		mouse_position = board_intersect.position


func init_move(piece):
	if (is_white_turn and piece.color == Piece.PieceColor.WHITE) \
			or (not is_white_turn and piece.color == Piece.PieceColor.BLACK):
		move_mode = true
		mouse_piece = piece
		previous_position = piece.position
		previous_cell = get_cell(previous_position)
		glow_valid_moves(true)
		

func glow_valid_moves(glow):
	for k in cells.keys():
		var cell: Cell = cells[k]
		if glow:
			if is_valid_move(Vector3i(cell.position), true):
				cell.color = Color(1, 0.5, 0.5, cell.color.a)
		else:
			cell.color = Color(1, 1, 1, cell.color.a)


func process_move(delta):
	mouse_cell = get_cell(mouse_position)
	if mouse_cell:
		mouse_piece.position = mouse_piece.position.lerp(mouse_cell.center + Vector3(0, 1.0/4, 0), 20 * delta)
	else:
		mouse_piece.position = mouse_piece.position.lerp(mouse_position + Vector3(0, 1.0/4, 0), 20 * delta)
	

func end_move():
	glow_valid_moves(false)
	
	if not move_mode:
		return
	
	var valid_move = verify_move()
	if valid_move:
		mouse_piece.position = mouse_cell.center
		previous_cell.piece = null
		mouse_cell.piece = mouse_piece
		mouse_piece.is_first_move = false
		update_in_sight()
		new_turn()
		%Camera/Camera3D/AudioStreamPlayer3D.play()
	else:
		mouse_piece.position = previous_position
		
	move_mode = false
	mouse_piece = null
	
	
func is_valid_move(new_position, preview):
	var old_position = Vector3i(previous_cell.position)

	for line in mouse_piece.sight_lines:
		for progress in line:
			var progress_position = old_position + progress
			var progress_cell = get_cell(progress_position)
			if not progress_cell:
				break
			if progress_position != new_position and progress_cell.piece:
				break
			if progress_position == new_position:
				if mouse_piece.type == Piece.PieceType.PAWN:
					return pawn_cases(old_position, progress, progress_cell.piece, preview)
				if mouse_piece.type == Piece.PieceType.KING:
					return king_cases(old_position, progress, progress_cell.piece, preview)
				if progress_cell.piece:
					if progress_cell.piece.color == mouse_piece.color:
						return false
					else:
						capture_piece(progress_cell.piece, preview)
				
				return true
				
	return false
	

func king_cases(old_position, progress, destiny_piece, preview):
	if mouse_piece.color == Piece.PieceColor.WHITE:
		if progress == Vector3i(2, 0, 0):
			if not mouse_piece.is_first_move:
				return false
			if get_cell(Vector3i(5, 0, 7)).piece:
				return false
			if get_cell(Vector3i(6, 0, 7)).piece:
				return false
			if not get_cell(Vector3i(7, 0, 7)).piece:
				return false
			if not preview:
				var tower = get_cell(Vector3i(7, 0, 7)).piece
				tower.position = Vector3(5.5, 0, 7.5)
				get_cell(Vector3i(5, 0, 7)).piece = tower
				get_cell(Vector3i(7, 0, 7)).piece = null
			return true
		if progress == Vector3i(-2, 0, 0):
			if not mouse_piece.is_first_move:
				return false
			if get_cell(Vector3i(3, 0, 7)).piece:
				return false
			if get_cell(Vector3i(2, 0, 7)).piece:
				return false
			if get_cell(Vector3i(1, 0, 7)).piece:
				return false
			if not get_cell(Vector3i(0, 0, 7)).piece:
				return false
			if not preview:
				var tower = get_cell(Vector3i(0, 0, 7)).piece
				tower.position = Vector3(3.5, 0, 7.5)
				get_cell(Vector3i(3, 0, 7)).piece = tower
				get_cell(Vector3i(0, 0, 7)).piece = null
			return true
	else:
		if progress == Vector3i(2, 0, 0):
			if not mouse_piece.is_first_move:
				return false
			if get_cell(Vector3i(5, 0, 0)).piece:
				return false
			if get_cell(Vector3i(6, 0, 0)).piece:
				return false
			if not get_cell(Vector3i(7, 0, 0)).piece:
				return false
			if not preview:
				var tower = get_cell(Vector3i(7, 0, 0)).piece
				tower.position = Vector3(5.5, 0, 0.5)
				get_cell(Vector3i(5, 0, 0)).piece = tower
				get_cell(Vector3i(7, 0, 0)).piece = null
			return true
		if progress == Vector3i(-2, 0, 0):
			if not mouse_piece.is_first_move:
				return false
			if get_cell(Vector3i(3, 0, 0)).piece:
				return false
			if get_cell(Vector3i(2, 0, 0)).piece:
				return false
			if get_cell(Vector3i(1, 0, 0)).piece:
				return false
			if not get_cell(Vector3i(0, 0, 0)).piece:
				return false
			if not preview:
				var tower = get_cell(Vector3i(0, 0, 0)).piece
				tower.position = Vector3(3.5, 0, 0.5)
				get_cell(Vector3i(3, 0, 0)).piece = tower
				get_cell(Vector3i(0, 0, 0)).piece = null
			return true
	
	if destiny_piece:
		if destiny_piece.color == mouse_piece.color:
			return false
		else:
			capture_piece(destiny_piece, preview)
			
	return true
			

func pawn_cases(old_position, progress, destiny_piece, preview):
	var valid_move = pawn_move(old_position, progress, destiny_piece, preview)
	if not valid_move:
		return false
	
	if preview:
		return true
	
	if mouse_piece.color == Piece.PieceColor.WHITE:
		if old_position + progress in [
				Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(3, 0, 0), 
				Vector3i(4, 0, 0), Vector3i(5, 0, 0), Vector3i(6, 0, 0), Vector3i(7, 0, 0)]:
			mouse_piece.type = Piece.PieceType.QUEEN
			mouse_piece.body.frame = 9
			mouse_piece.get_lines_by_type(mouse_piece.type)
			update_in_sight()
	else:
		if old_position + progress in [
				Vector3i(0, 0, 7), Vector3i(1, 0, 7), Vector3i(2, 0, 7), Vector3i(3, 0, 7), 
				Vector3i(4, 0, 7), Vector3i(5, 0, 7), Vector3i(6, 0, 7), Vector3i(7, 0, 7)]:
			mouse_piece.type = Piece.PieceType.QUEEN
			mouse_piece.body.frame = 3
			mouse_piece.get_lines_by_type(mouse_piece.type)
			update_in_sight()
	
	return true
	

func pawn_move(old_position, progress, destiny_piece, preview):
	if mouse_piece.color == Piece.PieceColor.WHITE:
		if progress == Vector3i(-1, 0, -1):
			if destiny_piece and not destiny_piece.color == mouse_piece.color:
				capture_piece(destiny_piece, preview)
				return true
			elif mouse_piece.piece_capturable_en_passant \
					and get_cell(old_position + Vector3i(-1, 0, 0)).piece == \
					mouse_piece.piece_capturable_en_passant:
				capture_piece(mouse_piece.piece_capturable_en_passant, preview)
				return true
			else:
				return false
		elif progress == Vector3i(1, 0, -1):
			if destiny_piece and not destiny_piece.color == mouse_piece.color:
				capture_piece(destiny_piece, preview)
				return true
			elif mouse_piece.piece_capturable_en_passant \
					and get_cell(old_position + Vector3i(1, 0, 0)).piece == \
					mouse_piece.piece_capturable_en_passant:
				capture_piece(mouse_piece.piece_capturable_en_passant, preview)
				return true
			else:
				return false
		elif progress == Vector3i(0, 0, -2) and mouse_piece.is_first_move:
			return true
		elif progress == Vector3i(0, 0, -1):
			if destiny_piece:
				return false
			var left_cell = get_cell(old_position + Vector3i(-1, 0, -1))
			if left_cell and left_cell.piece \
					and left_cell.piece.color == Piece.PieceColor.BLACK \
					and left_cell.piece.type == Piece.PieceType.PAWN:
				left_cell.piece.piece_capturable_en_passant = mouse_piece
			var right_cell = get_cell(old_position + Vector3i(1, 0, -1))
			if right_cell and right_cell.piece \
					and right_cell.piece.color == Piece.PieceColor.BLACK \
					and right_cell.piece.type == Piece.PieceType.PAWN:
				right_cell.piece.piece_capturable_en_passant = mouse_piece
			return true
		else:
			return false
			
	elif mouse_piece.color == Piece.PieceColor.BLACK:
		if progress == Vector3i(-1, 0, 1):
			if destiny_piece and not destiny_piece.color == mouse_piece.color:
				capture_piece(destiny_piece, preview)
				return true
			elif mouse_piece.piece_capturable_en_passant \
					and get_cell(old_position + Vector3i(-1, 0, 0)).piece == \
					mouse_piece.piece_capturable_en_passant:
				capture_piece(mouse_piece.piece_capturable_en_passant, preview)
				return true
			else:
				return false
		elif progress == Vector3i(1, 0, 1):
			if destiny_piece and not destiny_piece.color == mouse_piece.color:
				capture_piece(destiny_piece, preview)
				return true
			elif mouse_piece.piece_capturable_en_passant \
					and get_cell(old_position + Vector3i(1, 0, 0)).piece == \
					mouse_piece.piece_capturable_en_passant:
				capture_piece(mouse_piece.piece_capturable_en_passant, preview)
				return true
			else:
				return false
		elif progress == Vector3i(0, 0, 2) and mouse_piece.is_first_move:
			return true
		elif progress == Vector3i(0, 0, 1):
			if destiny_piece:
				return false
			var left_cell = get_cell(old_position + Vector3i(-1, 0, 1))
			if left_cell and left_cell.piece \
					and left_cell.piece.color == Piece.PieceColor.WHITE \
					and left_cell.piece.type == Piece.PieceType.PAWN:
				left_cell.piece.piece_capturable_en_passant = mouse_piece
			var right_cell = get_cell(old_position + Vector3i(1, 0, 1))
			if right_cell and right_cell.piece \
					and right_cell.piece.color == Piece.PieceColor.WHITE \
					and right_cell.piece.type == Piece.PieceType.PAWN:
				right_cell.piece.piece_capturable_en_passant = mouse_piece
			return true
		else:
			return false
	
	
func capture_piece(piece, preview):
	if preview:
		return
		
	white_pieces.erase(piece)
	black_pieces.erase(piece)
	piece.queue_free()
	if white_king not in white_pieces:
		is_end_game = true
		win(false)
	if black_king not in black_pieces:
		is_end_game = true
		win(true)
	

func verify_move():
	if not mouse_cell:
		return false
	if not mouse_cell.in_sight:
		return false
	if not is_valid_move(Vector3i(mouse_cell.position), false):
		return false
	return true


func new_turn():
	if is_end_game:
		return
		
	is_white_turn = not is_white_turn
	%WhiteTurn.visible = is_white_turn
	%BlackTurn.visible = not is_white_turn
	%Cover.visible = true
	switch_color()


func ready():
	%Cover.visible = false


func update_in_sight():
	if is_end_game:
		return
		
	for k in cells.keys():
		var cell: Cell = cells[k]
		cell.in_sight = false

	var pieces = white_pieces if player_is_white else black_pieces
	for piece in pieces:
		var piece_cell = get_cell(Vector3i(piece.position))
		piece_cell.in_sight = true
		
		for line in piece.sight_lines:
			for progress in line:
				var progress_position = Vector3i(piece.position) + progress
				var progress_cell = get_cell(progress_position)
				
				if not progress_cell:
					break
				
				progress_cell.in_sight = true
				
				if progress_cell.piece:
					break
					
	for k in cells.keys():
		var cell: Cell = cells[k]
		
		if cell.in_sight:
			cell.color = Color(1, 1, 1, 1)
			if cell.piece:
				cell.piece.visible = true
		else:
			cell.color = Color(1, 1, 1, 0)
			if cell.piece:
				cell.piece.visible = false


func switch_color():
	player_is_white = not player_is_white
	update_in_sight()
	camera.reset(player_is_white)
	

func reset_game():
	get_tree().reload_current_scene()
	

func win(white_is_winner):
	for k in cells.keys():
		var cell: Cell = cells[k]
		cell.color = Color(1, 1, 1, 1)
		if cell.piece:
			cell.piece.visible = true
			
	%Win.visible = true
	if white_is_winner:
		%WhiteWinner.visible = true
	else:
		%BlackWinner.visible = true


func get_cell(_position):
	return cells.get(Vector3i(floor(_position.x), 0, floor(_position.z)))
