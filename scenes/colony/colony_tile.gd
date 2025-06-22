extends Node2D

const WorldMapTilemap = preload("res://scenes/colony/world_map_tilemap.gd")
const WorldMap = preload("res://scenes/colony/world_map.gd")
const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys

const TileTypes: Dictionary[StringName, Vector2i] = {
	GRASS = Vector2i(0, 0),
	WATER = Vector2i(1, 0),
	SAND = Vector2i(2, 0),
	HOUSE = Vector2i(0, 3),
	TOWN_CENTRE = Vector2i(3, 0),
	TREE = Vector2i(0, 1),
}
const SIZE := 10
const WCOORD := Vector2i.ONE * -1

const SAVE_PATH := "user://pubtest/colony/tiles/"

var tilepos: Vector2i = WCOORD
@onready var tiles: TileMapLayer = $Tiles
@export var cursor: Node2D
@export var info: Label


func _option_init(options := {}) -> void:
	tilepos = options.get("pos", WCOORD)
	if not save_exists():
		generate(options.get("type", Vector2i(-1, -1)))
	else:
		_load()


func _ready() -> void:
	%BackButton.pressed.connect(func():
		_save()
		LTS.change_scene_to("res://scenes/colony/world_map.tscn")
	)
	tiles.clear()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var epos: Vector2 = get_canvas_transform().affine_inverse() * event.global_position
		var tpos := tiles.local_to_map(tiles.to_local(epos))

		if cursor:
			cursor.global_position = tpos * tiles.tile_set.tile_size

		if info:
			info.text = "Tile at " + str(tpos)
			info.text += "\nType: " + str(TileTypes.find_key(tiles.get_cell_atlas_coords(tpos)))
			info.text += "\nColony Tile at: " + str(tilepos)

	if event is InputEventMouseButton:
		var epos: Vector2 = get_canvas_transform().affine_inverse() * event.global_position
		var tpos := tiles.local_to_map(tiles.to_local(epos))
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("wow you clicked the tile. good joü")


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
	var towncentre: Vector2i = dat.gets(dk.CENTRE_TILE, WCOORD)
	if towncentre == WCOORD:
		dat.sets(dk.CENTRE_TILE, Vector2i(4, 4))
		tiles.set_cell(Vector2i(4, 4), 0, TileTypes.TOWN_CENTRE)


func _save() -> void:
	if tilepos == WCOORD:
		printerr("uuuuughhhhhh cant save man cant do it")
		return
	print("immm saving ti.")

	var dict := {}
	for cellpos in tiles.get_used_cells():
		#print("saving tiel at ", cellpos)
		var type := tiles.get_cell_atlas_coords(cellpos)
		dict[cellpos] = type

	dat.gets(dk.SAVED_CTILES)[tilepos] = dict


func _load() -> void:
	if not save_exists():
		return
	var save: Dictionary = dat.gets(dk.SAVED_CTILES)
	for pos in save[tilepos]:
		var type: Vector2i = save[tilepos][pos]
		tiles.set_cell(pos, 0, type)


func save_exists() -> bool:
	if tilepos == WCOORD:
		return false
	return tilepos in dat.gets(dk.SAVED_CTILES)
