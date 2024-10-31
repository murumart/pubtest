@tool
class_name MGActorGrid extends Node2D

const GRID_SIZE_PX := 16

@export var grid_size := Vector2i(12, 8)

var _spots := {}


func _ready() -> void:
	pass


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
