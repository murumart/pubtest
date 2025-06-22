extends Node2D

const WorldMapTilemap = preload("res://scenes/colony/world_map_tilemap.gd")
const SIZE := 10

const TileTypes: Dictionary[StringName, Vector2i] = {
	GRASS = Vector2i(0, 0),
	WATER = Vector2i(1, 0),
	SAND = Vector2i(2, 0),
	HOUSE = Vector2i(3, 0),
	TREE = Vector2i(0, 1),
}

const SAVE_PATH := "user://pubtest/colony/tiles/"

var tilename: String
@onready var tiles: TileMapLayer = $Tiles


func _option_init(options := {}) -> void:
	tilename = options.get("name", "")
	if not save_exists():
		generate(options.get("type", Vector2i(-1, -1)))
	else:
		_load()


func _ready() -> void:
	$Camera2D/Control/BackButton.pressed.connect(func():
		_save()
		LTS.change_scene_to("res://scenes/colony/world_map.tscn")
	)
	tiles.clear()


func generate(type: Vector2i) -> void:
	const wmt := WorldMapTilemap.TileTypes
	if type == wmt.SEA:
		for y in SIZE:
			for x in SIZE:
				tiles.set_cell(Vector2i(x, y), 0, TileTypes.WATER)
	else:
		for y in SIZE:
			for x in SIZE:
				tiles.set_cell(Vector2i(x, y), 0, TileTypes.GRASS)
				if randf() < 0.1:
					tiles.set_cell(Vector2i(x, y), 0, TileTypes.TREE)
				elif randf() < 0.1:
					tiles.set_cell(Vector2i(x, y), 0, TileTypes.SAND)


func _save() -> void:
	if not tilename:
		printerr("uuuuughhhhhh cant save man cant do it")
		return
	print("immm saving ti.")
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_recursive_absolute(SAVE_PATH)
	var fa := FileAccess.open(SAVE_PATH + tilename + ".tle", FileAccess.WRITE)
	var cells := tiles.get_used_cells()
	for cellpos in cells:
		#print("saving tiel at ", cellpos)
		var type := tiles.get_cell_atlas_coords(cellpos)
		fa.store_var(cellpos)
		fa.store_var(type)


func _load() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		return
	var fa := FileAccess.open(SAVE_PATH + tilename + ".tle", FileAccess.READ)
	tiles.clear()
	while fa.get_position() < fa.get_length():
		#print("öööö")
		var pos: Vector2i = fa.get_var()
		var type: Vector2i = fa.get_var()
		tiles.set_cell(pos, 0, type)


func save_exists() -> bool:
	if not tilename:
		return false
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_recursive_absolute(SAVE_PATH)
	return FileAccess.file_exists(SAVE_PATH + tilename + ".tle")
