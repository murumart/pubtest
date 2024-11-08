@tool
class_name MGActorGrid extends Node2D

const GRID_SIZE_PX := 16

@export var grid_size := Vector2i(12, 8)

var spots := Spots.new()


func _ready() -> void:
	for child: MGCharacter in get_children():
		spots.let(pos_to_spot(child.position), child)
		child.move_requested.connect(move_character)


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


func pos_to_spot(pos: Vector2) -> Vector2i:
	return Vector2i((pos / GRID_SIZE_PX).floor())


func global_pos_to_spot(global_pos: Vector2) -> Vector2i:
	return pos_to_spot(to_local(global_pos))


func get_characters() -> Array[MGCharacter]:
	return spots.get_values()


func move_character(who: MGCharacter, to: Vector2) -> void:
	assert(spots.who(to) == null)
	spots.erase_char(who)
	spots.let(Vector2i(to), who)
	who.position = to * GRID_SIZE_PX + Vector2.ONE * GRID_SIZE_PX * 0.5


class Spots:
	var _data := {}


	func let(pos: Vector2i, chara: MGCharacter) -> void:
		_data[pos] = chara


	func erase(pos: Vector2i) -> void:
		_data.erase(pos)


	func erase_char(chara: MGCharacter) -> void:
		_data.erase(_data.find_key(chara))


	func who(pos: Vector2i) -> MGCharacter:
		return _data.get(pos, null)


	func get_values() -> Array[MGCharacter]:
		var new_cool_memory: Array[MGCharacter] = []
		new_cool_memory.assign(_data.values())
		return new_cool_memory
