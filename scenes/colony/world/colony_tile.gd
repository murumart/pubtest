extends Node2D

const WorldMapTilemap = preload("res://scenes/colony/world/world_map_tilemap.gd")
const WorldMap = preload("res://scenes/colony/world/world_map.gd")
const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const Jobs = preload("res://scenes/colony/jobs.gd")
const CTileUI = preload("res://scenes/colony/world/ctile_ui.gd")
const Resources = preload("res://scenes/colony/resources.gd")
const Workers = preload("res://scenes/colony/workers.gd")
const CtileJobs = preload("res://scenes/colony/world/ctile_jobs.gd")

const TileTypes: Dictionary[StringName, Vector2i] = {
	GRASS = Vector2i(0, 0),
	WATER = Vector2i(1, 0),
	SAND = Vector2i(2, 0),
	HOUSE = Vector2i(0, 3),
	CAMPFIRE = Vector2i(0, 2),
	TOWN_CENTRE = Vector2i(3, 0),
	TREE = Vector2i(0, 1),
	PEBBLES = Vector2i(1, 1),
	BOULDER = Vector2i(2, 1),
}

const SIZE := 10
const WCOORD := Vector2i.ONE * -1

const SAVE_PATH := "user://pubtest/colony/tiles/"

var ctile_pos: Vector2i = WCOORD
var ctile_type: Vector2i
var jobs: Array[Jobs.Job]:
	get:
		jobs = jobs.filter(func(j: Jobs.Job) -> bool: return is_instance_valid(j) and j != null)
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
		LTS.change_scene_to("res://scenes/colony/world/colony_tile.tscn", {pos = ctile_pos, type = ctile_type})
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


func _tile_clicked(pos: Vector2i) -> void:
	var type := tiles.get_cell_atlas_coords(pos)
	var aval_jobs: Dictionary[String, Jobs.Job] = {}
	var overlapping := jobs.filter(func(j: Jobs.Job) -> bool:
		return is_instance_valid(j) and j.map_tile == pos)
	match type:
		WCOORD:
			return
		TileTypes.TREE:
			if await if_overlap_adjust_jobs(pos, overlapping):
				return
			aval_jobs.merge(CtileJobs.get_tree_jobs(pos, ctile_pos))
		TileTypes.PEBBLES:
			if await if_overlap_adjust_jobs(pos, overlapping):
				return
			aval_jobs.merge(CtileJobs.get_pebble_jobs(pos, ctile_pos))
		TileTypes.GRASS, TileTypes.SAND:
			if await if_overlap_adjust_jobs(pos, overlapping):
				return
			aval_jobs.merge(CtileJobs.get_building_jobs(pos, ctile_pos))
		TileTypes.WATER:
			if await if_overlap_adjust_jobs(pos, overlapping):
				return
			aval_jobs.merge(CtileJobs.get_fishing_jobs(pos, ctile_pos))
		TileTypes.CAMPFIRE:
			if await if_overlap_adjust_jobs(pos, overlapping):
				return
			aval_jobs.merge(CtileJobs.get_cooking_jobs(pos, ctile_pos))

	var sp := SelectionPopup.create()
	ui.add_child(sp)
	var job := await CtileJobs.select_job(sp, aval_jobs)
	if job != null:
		if job is Jobs.JobError:
			SOL.vfx("damage_number", Vector2(pos) * 16, {text = job.title})
			return
		jobs.append(job)
		await ui.local_job_worker_adjust(job)
		ui.update_active_jobs(jobs)


static func get_tiles(cpos: Vector2i) -> Dictionary:
	return dat.gets(dk.SAVED_CTILES)[cpos]


static func get_tile(cpos: Vector2i, mappos: Vector2i) -> Vector2i:
	return get_tiles(cpos)[mappos]


static func set_tile(cpos: Vector2i, mappos: Vector2i, to: Vector2i) -> void:
	get_tiles(cpos)[mappos] = to


static func replace_tile(
	what: Vector2i,
	with: Vector2i,
	where_close: Vector2i,
	where_far: Vector2i
) -> void:
	if get_tile(where_far, where_close) == what:
		set_tile(where_far, where_close, with)


func if_overlap_adjust_jobs(_pos: Vector2i, overlapping: Array) -> bool:
	if not overlapping.is_empty():
		await ui.local_job_worker_adjust(overlapping[0])
		ui.update_active_jobs(jobs)
		return true
	return false


func generate(_type: Vector2i) -> void:
	var noise := WorldMapTilemap.noise
	var tile: Vector2i

	for y in SIZE:
		for x in SIZE:
			var wpos := ctile_pos * WorldMapTilemap.SIZE + Vector2i(x, y)
			var nval := noise.get_noise_2d(wpos.x, wpos.y)
			if nval < 0:
				tile = TileTypes.WATER
			elif nval < 0.04:
				tile = TileTypes.SAND
			else:
				tile = TileTypes.GRASS

			if tile == TileTypes.GRASS:
				if randf() < 0.1:
					tile = TileTypes.TREE
				elif randf() < 0.1:
					tile = TileTypes.SAND
				elif randf() < 0.1:
					tile = TileTypes.PEBBLES
				elif randf() < 0.05:
					tile = TileTypes.BOULDER

			tiles.set_cell(Vector2i(x, y), 0, tile)

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
