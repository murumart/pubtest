extends Control

const WMM := preload("res://scenes/colony/world/world_map_tilemap.gd")
const ColonyTile = preload("res://scenes/colony/world/colony_tile.gd")
const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const ColonyMain = preload("res://scenes/colony/colony_main.gd")
const Civs = preload("res://scenes/colony/civs.gd")
const CtileUi = preload("res://scenes/colony/world/ctile_ui.gd")
const Resources = preload("res://scenes/colony/resources.gd")
const Jobs = preload("res://scenes/colony/jobs.gd")

const SAVE_PATH := "user://pubtest/colony/"
const FILENAME := "worldmap.save"

var data := {}
var loaded_ctiles: Dictionary[Vector2i, ColonyTile]

@onready var world_map: WMM = $WorldMap
@onready var camera_2d: Camera2D = $Camera2D
@onready var civ_info: Label = $CanvasLayer/CivInfo
@onready var ctiles: Node2D = $CTiles
@onready var ui: CtileUi = $CanvasLayer/Ui


func _ready() -> void:
	ui.time_pass_request.connect(func(amt: int) -> void:
		_save()
		Resources.pass_time(amt)
		for pos in loaded_ctiles:
			loaded_ctiles[pos].free()
			load_tile(pos)
		#LTS.change_scene_to("res://scenes/colony/world/colony_tile.tscn", {pos = ctile_pos, type = ctile_type})
	)
	ui.job_removal_request.connect(func(j: Jobs.Job) -> void:
		Jobs.cancel_job_j(j)
	)
	for t in Civs.civs[0].claimed_tiles:
		load_tile(t)


func _unhandled_input(_event: InputEvent) -> void:
	civ_info.text = "Standing with Civs:"
	var myciv := Civs.civs[0]
	for i in Civs.civs.size():
		var stnding: int = myciv.standing.get(i, 0)
		civ_info.text += "\n" + Civs.civs[i].name + ": " + str(stnding)
		# game over condition
		if i == 0 and stnding < 0:
			LTS.change_scene_to("res://scenes/colony/game_over.tscn")


func _option_init(opt: Dictionary) -> void:
	world_map.tile_clicked.connect(_tile_clicked)
	if opt.get("first", false):
		world_map.generate()
		_save()
	else:
		_load()
	camera_2d.global_position = Vector2(WMM.SIZE, WMM.SIZE) * 16 * world_map.scale.x * 0.5
	var z := 32.0 / WMM.SIZE
	camera_2d.zoom = Vector2(z, z)


func _tile_clicked(pos: Vector2i, tiletype: Vector2i, claimed: bool) -> void:
	var acceptable := false
	if not claimed:
		for cmd in Civs.civs[0].claimed_tiles:
			if cmd.distance_squared_to(pos) <= 2:
				ColonyMain.loge("you claimed this tile!!! wow!!!")
				Civs.civs[0].lay_claim(pos)
				acceptable = true
				break
	#LTS.change_scene_to("res://scenes/colony/world/colony_tile.tscn", {pos = pos, type = tiletype})
	if claimed or not is_instance_valid(loaded_ctiles.get(pos, null)) and acceptable:
		load_tile(pos)


func load_tile(where: Vector2i) -> void:
	var tile := load("res://scenes/colony/world/colony_tile.tscn").instantiate() as ColonyTile
	loaded_ctiles[where] = tile
	tile.ui = ui
	ctiles.add_child(tile)
	tile.global_position = where * 16 * world_map.scale.x
	tile.map_init(where)


func save_me() -> void:
	_save()


func _load() -> void:
	world_map.loadf(dat.gets(dk.WORLD_MAP))


func _save() -> void:
	dat.sets(dk.WORLD_MAP, world_map.savef())


static func ctile_name(pos: Vector2i) -> String:
	return "x" + str(pos.x) + "_y" + str(pos.y)
