extends Control

const WMM := preload("res://scenes/colony/world_map_tilemap.gd")
const ColonyTile = preload("res://scenes/colony/colony_tile.gd")

const SAVE_PATH := "user://pubtest/colony/"
const FILENAME := "worldmap.save"

var data := {}

@onready var world_map: WMM = $WorldMap


func _option_init(opt: Dictionary) -> void:
	world_map.tile_clicked.connect(_tile_clicked)
	if opt.get("first", false):
		world_map.generate()
		_save()
	else:
		_load()


func _tile_clicked(pos: Vector2i, tiletype: Vector2i, claimed: bool) -> void:
	if not claimed:
		for cmd in world_map.claimed_tiles:
			if cmd.distance_squared_to(pos) <= 2:
				print("you claimed this tile!!! wow!!!")
				world_map.claimed_tiles.append(pos)
				return
		return
	_save()
	LTS.change_scene_to("res://scenes/colony/colony_tile.tscn", {name = tile_name(pos), type = tiletype})


func _load() -> void:
	assert(DirAccess.dir_exists_absolute(SAVE_PATH))
	var fa := FileAccess.open(SAVE_PATH + FILENAME, FileAccess.READ)
	data = fa.get_var()
	world_map.loadf(data["world_map"])


func _save() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_recursive_absolute(SAVE_PATH)
	var fa := FileAccess.open(SAVE_PATH + FILENAME, FileAccess.WRITE)
	data["world_map"] = world_map.savef()
	fa.store_var(data)


func tile_name(pos: Vector2i) -> String:
	return "x" + str(pos.x) + "_y" + str(pos.y)
