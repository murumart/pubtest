@tool
class_name MGActorGrid extends Node2D

const GRID_SIZE_PX := 16

@export var grid_size := Vector2i(12, 8)

var _spots := {}


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	for x in grid_size.x:
		for y in grid_size.y:
			draw_rect(
					Rect2(Vector2(x, y) * GRID_SIZE_PX,
							Vector2.ONE * GRID_SIZE_PX),
					Color.CORNFLOWER_BLUE,
					false
			)


func move_to(who: MGCharacter, to: Vector2i) -> void:
	if not can_move_to(who, to):
		return
	who.position = (Vector2(to) * GRID_SIZE_PX
			- Vector2.ONE * GRID_SIZE_PX * 0.5)


func can_move_to(who: MGCharacter, to: Vector2i) -> bool:
	if not who in get_children():
		return false
	if (to.x >= grid_size.x or to.x < 0
		or to.y >= grid_size.y or to.y < 0
	):
		return false
	return true


func get_characters() -> Array[MGCharacter]:
	var a: Array[MGCharacter] = []
	a.assign(get_children())
	return a
