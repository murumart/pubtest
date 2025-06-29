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
const WCOORD := -Vector2i.ONE

const SAVE_PATH := "user://pubtest/colony/tiles/"

var focused := false
var ctile_pos: Vector2i = WCOORD
var ctile_type: Vector2i
var jobs: Array[Jobs.Job]:
	get:
		jobs = jobs.filter(func(j: Jobs.Job) -> bool: return is_instance_valid(j) and j != null)
		if is_instance_valid(draw_jobs): draw_jobs.queue_redraw()
		return jobs
@onready var tiles: TileMapLayer = $Tiles
@export var ui: CTileUI
@onready var draw_jobs: Node2D = $DrawJobs


func map_init(cpos: Vector2i) -> void:
	ctile_pos = cpos
	if not save_exists():
		generate()
		_save()
	else:
		_load()


func _ready() -> void:

	tiles.clear()
	ui.update_active_jobs(jobs)
	ui.active_jobs_list.mouse_entered.connect(func() -> void: ui.update_active_jobs(jobs))
	ui.job_removal_request.connect(func(j: Jobs.Job) -> void:
		jobs.erase(j)
		ui.update_active_jobs(jobs)
	)
	draw_jobs.draw.connect(func() -> void:
		for j in jobs:
			draw_jobs.draw_rect(Rect2(j.map_tile * 16, Vector2(16, 16)), Color(Color.RED, 0.5), false, 1)
	)


func _unhandled_input(event: InputEvent) -> void:
	var mousepos := tiles.to_local(get_global_mouse_position())
	var tpos := tiles.local_to_map(mousepos)
	if tpos.x < 0 or tpos.x >= SIZE or tpos.y < 0 or tpos.y >= SIZE:
		focused = false
		return

	if not focused:
		ui.update_active_jobs(jobs)
	focused = true

	if event is InputEventMouseMotion:
		ui.update_cursor(tpos, self)

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			_tile_clicked(tpos)

	ui.update_resources()


func _tile_clicked(pos: Vector2i) -> void:
	var type := tiles.get_cell_atlas_coords(pos)
	var aval_jobs: Dictionary[String, Jobs.Job] = {}
	var overlapping := jobs.filter(func(j: Jobs.Job) -> bool:
		return is_instance_valid(j) and j.map_tile == pos)
	if type == WCOORD:
		return
	if await if_overlap_adjust_jobs(pos, overlapping):
		return
	if type == TileTypes.TREE:
		aval_jobs.merge(CtileJobs.get_tree_jobs(pos, ctile_pos))
	if type == TileTypes.PEBBLES:
		aval_jobs.merge(CtileJobs.get_pebble_jobs(pos, ctile_pos))
	if type == TileTypes.BOULDER:
		aval_jobs.merge(CtileJobs.get_boulder_jobs(pos, ctile_pos))
	if type in [TileTypes.GRASS, TileTypes.SAND]:
		aval_jobs.merge(CtileJobs.get_building_jobs(pos, ctile_pos))
	if type == TileTypes.GRASS:
		aval_jobs.merge(CtileJobs.get_planting_jobs(pos, ctile_pos))
	if type == TileTypes.WATER:
		aval_jobs.merge(CtileJobs.get_fishing_jobs(pos, ctile_pos))
	if type == TileTypes.CAMPFIRE:
		aval_jobs.merge(CtileJobs.get_cooking_jobs(pos, ctile_pos))
	if type == TileTypes.HOUSE:
		aval_jobs.merge(CtileJobs.get_house_jobs(pos, ctile_pos))
	if type in [TileTypes.HOUSE, TileTypes.TOWN_CENTRE]:
		aval_jobs.merge(CtileJobs.get_residence_jobs(pos, ctile_pos))

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


func generate() -> void:
	var noise := WorldMapTilemap.noise
	var tile: Vector2i

	for y in SIZE:
		for x in SIZE:
			var wpos := ctile_pos * SIZE + Vector2i(x, y)
			var nval := noise.get_noise_2d(wpos.x, wpos.y)
			if nval < 0:
				tile = TileTypes.WATER
			elif nval < 0.01:
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
				elif randf() < 0.01:
					tile = TileTypes.BOULDER

			tiles.set_cell(Vector2i(x, y), 0, tile)

	var towncentre: Vector2i = dat.gets(dk.CENTRE_TILE, WCOORD)
	if towncentre == WCOORD:
		# first tile that is generated gets the town centre
		dat.sets(dk.CENTRE_TILE, Vector2i(4, 4))
		tiles.set_cell(Vector2i(4, 4), 0, TileTypes.TOWN_CENTRE)
		var residence := Workers.create_residence(ctile_pos, Vector2i(4, 4), 3)
		# all initial workers live in the town centre at first
		for w in Workers.workers:
			Workers.move_residence(w, null, residence)


func _save() -> void:
	if ctile_pos == WCOORD:
		printerr("uuuuughhhhhh cant save man cant do it")
		return

	var dict := {}
	for cellpos in tiles.get_used_cells():
		#print("saving tiel at ", cellpos)
		var type := tiles.get_cell_atlas_coords(cellpos)
		dict[cellpos] = type
	dict["jobs"] = jobs.map(func(j: Jobs.Job) -> int: return j.reg_index)

	print("immm saving ti.")
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
