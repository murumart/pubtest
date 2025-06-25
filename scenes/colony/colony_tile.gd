extends Node2D

const WorldMapTilemap = preload("res://scenes/colony/world_map_tilemap.gd")
const WorldMap = preload("res://scenes/colony/world_map.gd")
const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const Jobs = preload("res://scenes/colony/jobs.gd")
const CTileUI = preload("res://scenes/colony/ctile_ui.gd")
const Resources = preload("res://scenes/colony/resources.gd")
const Workers = preload("res://scenes/colony/workers.gd")

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

var ctile_pos: Vector2i = WCOORD
var ctile_type: Vector2i
var jobs: Array[Jobs.Job]:
	get:
		jobs = jobs.filter(func(j: Jobs.Job) -> bool: return is_instance_valid(j) and j != null)
		print("jobs acccessed: ", jobs)
		return jobs
@onready var tiles: TileMapLayer = $Tiles
@export var ui: CTileUI


func _option_init(options := {}) -> void:
	ctile_pos = options.get("pos", WCOORD)
	ctile_type = options.get("type", WCOORD)
	if not save_exists():
		generate(ctile_type)
	else:
		_load()


func _ready() -> void:
	ui.time_pass_request.connect(func(amt: int) -> void:
		_save()
		Resources.pass_time(amt)
		LTS.change_scene_to("res://scenes/colony/colony_tile.tscn", {pos = ctile_pos, type = ctile_type})
	)
	tiles.clear()
	ui.update_active_jobs(jobs)
	ui.active_jobs_list.mouse_entered.connect(func() -> void: ui.update_active_jobs(jobs))
	ui.job_removal_request.connect(func(j: Jobs.Job) -> void:
		jobs.erase(j)
		Jobs.cancel_job_j(j)
		ui.update_active_jobs(jobs)
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var epos: Vector2 = get_canvas_transform().affine_inverse() * event.global_position
		var tpos := tiles.local_to_map(tiles.to_local(epos))
		ui.update_cursor(tpos, self)

	if event is InputEventMouseButton:
		var epos: Vector2 = get_canvas_transform().affine_inverse() * event.global_position
		var tpos := tiles.local_to_map(tiles.to_local(epos))
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_tile_clicked(tpos)

	ui.update_resources()


static func get_tiles(cpos: Vector2i) -> Dictionary:
	return dat.gets(dk.SAVED_CTILES)[cpos]


static func get_tile(cpos: Vector2i, mappos: Vector2i) -> Vector2i:
	return get_tiles(cpos)[mappos]


static func set_tile(cpos: Vector2i, mappos: Vector2i, to: Vector2i) -> void:
	get_tiles(cpos)[mappos] = to


func _tile_clicked(pos: Vector2i) -> void:
	var type := tiles.get_cell_atlas_coords(pos)
	var aval_jobs: Dictionary[String, Variant] = {}
	match type:
		TileTypes.TREE:
			var overlapping := jobs.filter(func(j: Jobs.Job) -> bool: return is_instance_valid(j) and j.map_tile == pos)
			if not overlapping.is_empty():
				print("tile occupied")
				ui.local_job_worker_adjust(jobs.find(overlapping[0]))
				return
			aval_jobs = {
				"cut tree": (func() -> Jobs.Job:
					var job := Jobs.mk().set_time(60)
					job.ctile = ctile_pos
					job.map_tile = pos
					job.rewards = {"wood": 10}
					job.energy_usage = 35
					job.skill_reductions = {"woodcutting": 4}
					job.finished = Jobs.replace_tile.bind(TileTypes.TREE, TileTypes.GRASS, pos, ctile_pos)
					return job).call(),
				"hug tree": (func() -> Jobs.Job:
					var job := Jobs.mk().set_time(1)
					job.ctile = ctile_pos
					job.energy_usage = 1
					job.map_tile = pos
					job.rewards = {"love": 1}
					return job).call(),
			}
			var sp := SelectionPopup.create()
			ui.add_child(sp)
			var j = await sp.pop(
				sp.Parameters.new()
					.set_inputs_dt(aval_jobs)
					.set_title("select job")
					.set_result_callable(sp.wait_item_result)
					.set_ok_cancel(false, true))
			var job: Jobs.Job = j if not j is int else null
			if job != null:
				Jobs.add(job)
				jobs.append(job)
				print("added jop to " + str(pos))
			ui.update_active_jobs(jobs)


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
		# first tile that is generated gets the town centre
		dat.sets(dk.CENTRE_TILE, Vector2i(4, 4))
		tiles.set_cell(Vector2i(4, 4), 0, TileTypes.TOWN_CENTRE)
		# all initial workers live in the town centre at first
		for w in Workers.workers:
			if w.living_ctile == WCOORD:
				w.living_ctile = ctile_pos
			if w.living_maptile == WCOORD:
				w.living_maptile = Vector2i(4, 4)


func _save() -> void:
	if ctile_pos == WCOORD:
		printerr("uuuuughhhhhh cant save man cant do it")
		return
	print("immm saving ti.")

	var dict := {}
	for cellpos in tiles.get_used_cells():
		#print("saving tiel at ", cellpos)
		var type := tiles.get_cell_atlas_coords(cellpos)
		dict[cellpos] = type
	dict["jobs"] = jobs.map(func(j: Jobs.Job) -> int: return Jobs.jobs.find(j))

	dat.gets(dk.SAVED_CTILES)[ctile_pos] = dict


func _load() -> void:
	if not save_exists():
		return
	var save: Dictionary = dat.gets(dk.SAVED_CTILES)
	var a: Array = (save[ctile_pos]["jobs"].map(func(i: int) -> Jobs.Job: return Jobs.jobs[i]))
	jobs.assign(a)
	for pos in save[ctile_pos]:
		if pos is not Vector2i:
			continue
		var type: Vector2i = save[ctile_pos][pos]
		tiles.set_cell(pos, 0, type)
	ui.update_active_jobs(jobs)


func save_exists() -> bool:
	if ctile_pos == WCOORD:
		return false
	return ctile_pos in dat.gets(dk.SAVED_CTILES)
