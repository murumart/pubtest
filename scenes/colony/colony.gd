extends Node2D

const UI := preload("res://scenes/colony/ui.gd")
const Cam := preload("res://scenes/colony/movecamera.gd")

@export var camera: Cam
@export var ui: UI
@export var tiles: TileMapLayer


func _physics_process(delta: float) -> void:
	mousestuff()


func mousestuff() -> void:
	var mousepos := get_global_mouse_position()
	var tilepos := tiles.local_to_map(tiles.to_local(mousepos))

	var _err := draw.connect(func() -> void:
		draw_rect(Rect2(tilepos.x * 16, tilepos.y * 16, 16, 16), Color(Color.WHITE, 0.2))
	, CONNECT_ONE_SHOT)
	
	var tile: TileData = tiles.get_cell_tile_data(tilepos)
	ui.display_tile(tile, tilepos)
	
	if Input.is_action_just_pressed("click"):
		if not tile: return
		var id: int = tile.get_custom_data("tileid")
	
	queue_redraw()
