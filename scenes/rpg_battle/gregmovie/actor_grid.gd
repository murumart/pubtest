@tool
class_name MGActorGrid extends Node2D

const GRID_SIZE_PX := 16

@export var grid_size := Vector2i(12, 8)

var _spots := {}


func _ready() -> void:
	for mgc in get_characters():
		mgc.move_requested.connect(_move_requested)
		_spots[get_grid_position(mgc)] = mgc


func _draw() -> void:
	#if not Engine.is_editor_hint():
	#	return
	for x in grid_size.x:
		for y in grid_size.y:
			draw_rect(
					Rect2(Vector2(x, y) * GRID_SIZE_PX,
							Vector2.ONE * GRID_SIZE_PX),
					Color.CORNFLOWER_BLUE,
					false
			)


func _move_requested(action: MGMoveAction) -> void:
	move_in_dir(action.get_character(), action.direction)


func move_in_dir(who: MGCharacter, dir: Vector2i) -> void:
	var curr_pos: Vector2i = _spots.find_key(who)
	if not can_move_to(who, dir, curr_pos):
		return
	var moveto := dir + curr_pos
	_spots.erase(curr_pos)
	_spots[moveto] = who
	who.position = (Vector2(moveto) * GRID_SIZE_PX
			+ Vector2.ONE * GRID_SIZE_PX * 0.5)


func can_move_to(who: MGCharacter, dir: Vector2i, curr_pos: Vector2i) -> bool:
	if not who in get_children():
		return false
	var test_pos := dir + curr_pos
	if (test_pos.x >= grid_size.x or test_pos.x < 0
			or test_pos.y >= grid_size.y or test_pos.y < 0
			or test_pos in _spots
	):
		return false
	return true


func get_characters() -> Array[MGCharacter]:
	var a: Array[MGCharacter] = []
	a.assign(get_children())
	return a


func get_actionable_characters() -> Array[MGCharacter]:
	var a: Array[MGCharacter] = []
	a.assign(get_children().filter(func(a: Node) -> bool:
		return not (a as MGCharacter).is_acting))
	return a


func get_grid_position(mgchar: MGCharacter) -> Vector2i:
	return Vector2i((mgchar.position / GRID_SIZE_PX).floor())


func move_actors() -> void:
	for c in get_actionable_characters():
		c.component_movement.do_move(self)
