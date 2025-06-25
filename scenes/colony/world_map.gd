extends Control

const WMM := preload("res://scenes/colony/world_map_tilemap.gd")
const ColonyTile = preload("res://scenes/colony/colony_tile.gd")
const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const ColonyMain = preload("res://scenes/colony/colony_main.gd")

const SAVE_PATH := "user://pubtest/colony/"
const FILENAME := "worldmap.save"

var data := {}

@onready var world_map: WMM = $WorldMap
@onready var camera_2d: Camera2D = $Camera2D


func _option_init(opt: Dictionary) -> void:
	world_map.tile_clicked.connect(_tile_clicked)
	if opt.get("first", false):
		world_map.generate()
		_save()
	else:
		_load()
	camera_2d.global_position = Vector2(WMM.SIZE, WMM.SIZE) * 16 * 0.5
	var z := 32.0 / WMM.SIZE
	camera_2d.zoom = Vector2(z, z)


func _tile_clicked(pos: Vector2i, tiletype: Vector2i, claimed: bool) -> void:
	if not claimed:
		for cmd in world_map.claimed_tiles:
			if cmd.distance_squared_to(pos) <= 2:
				ColonyMain.loge("you claimed this tile!!! wow!!!")
				world_map.claimed_tiles.append(pos)
				return
		return
	LTS.change_scene_to("res://scenes/colony/colony_tile.tscn", {pos = pos, type = tiletype})


func save_me() -> void:
	_save()


func _load() -> void:
	world_map.loadf(dat.gets(dk.WORLD_MAP))


func _save() -> void:
	dat.sets(dk.WORLD_MAP, world_map.savef())


static func ctile_name(pos: Vector2i) -> String:
	return "x" + str(pos.x) + "_y" + str(pos.y)
