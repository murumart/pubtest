extends Control

const Workers = preload("res://scenes/colony/workers.gd")

signal time_pass_request(amt: int)
signal job_removal_request(job: Jobs.Job)

const ColonyTile = preload("res://scenes/colony/colony_tile.gd")
const TileTypes = ColonyTile.TileTypes
const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const res = preload("res://scenes/colony/resources.gd")
const Jobs = preload("res://scenes/colony/jobs.gd")

@export var cursor: Node2D
@export var tile_info_label: Label
@export var resource_info_label: Label
@export var time_info_label: Label
@export var active_jobs_list: ItemList
@export var workers_list: ItemList


func _ready() -> void:
	%BackButton.pressed.connect(func():
		owner._save()
		LTS.change_scene_to("res://scenes/colony/world_map.tscn")
	)
	%TimeButton.pressed.connect(func():
		var amt := int(%TimeButton.get_child(0).text)
		time_pass_request.emit(amt)
	)
	%WorkersButton.pressed.connect(func():
		var wl := $WorkersButton/PanelContainer
		wl.visible = !wl.visible
		if wl.visible:
			update_workers_list()
	)
	active_jobs_list.item_clicked.connect((local_job_worker_adjust).unbind(2))


func local_job_worker_adjust(ix: int) -> void:
	var sp := SelectionPopup.create()
	add_child(sp)
	var choice: int = await sp.pop(sp.Parameters.new()
		.set_title("add or remove worker")
		.set_inputs(["add worker", "remove worker", "cancel job"], [0, 1, 2])
		.set_result_callable(sp.wait_item_result)
		.set_ok_cancel(false, true)
	)

	sp = SelectionPopup.create()
	add_child(sp)
	var job: Jobs.Job = active_jobs_list.get_item_metadata(ix)

	if choice == 0:
		var available_workers := Workers.get_available_ixes()
		var worker: int = await sp.pop(sp.Parameters.new()
			.set_title("add worker")
			.set_inputs(Array(available_workers).map(func(a: int) -> String:
				return Workers.workers[a].name), available_workers)
			.set_result_callable(sp.wait_item_result)
			.set_ok_cancel(false, true)
		)
		print("owke ", worker)
		if worker >= 0:
			Jobs.assign_to_job(worker, job)
	elif choice == 1:
		var worker: int = await sp.pop(sp.Parameters.new()
			.set_title("remove worker")
			.set_inputs(Array(job.workers).map(func(a: int) -> String:
				return Workers.workers[a].name), Array(job.workers))
			.set_result_callable(sp.wait_item_result)
			.set_ok_cancel(false, true)
		)
		if worker >= 0:
			job.remove_worker(worker)
			print("removed worker")
	elif choice == 2:
		job_removal_request.emit(job)
		job.cancel()


func update_cursor(tpos: Vector2i, tile: ColonyTile) -> void:
	cursor.global_position = tpos * tile.tiles.tile_set.tile_size

	tile_info_label.text = "Tile at " + str(tpos)
	tile_info_label.text += "\nType: " + str(TileTypes.find_key(tile.tiles.get_cell_atlas_coords(tpos))).to_lower()
	tile_info_label.text += "\nColony Tile at: " + str(tile.ctile_pos)


func update_resources() -> void:
	var txt := ""
	for k in res.resources.keys():
		txt += str(k) + ": " + str(res.resources[k]) + "\n"
	resource_info_label.text = txt

	time_info_label.text = "Time: " + str(res.time) + " (%s)" % res.get_time_str() + "\nDay: " + str(res.day)


func update_active_jobs(jobs: Array[Jobs.Job]) -> void:
	print("updating jobs list..")
	active_jobs_list.clear()
	for job in jobs:
		# ignore finished jos
		if job not in Jobs.jobs or not is_instance_valid(job):
			continue
		var title := "job"
		if job.map_tile != Vector2i.ONE * -1:
			title += " at " + str(job.map_tile)
		var ix := active_jobs_list.add_item(title)
		active_jobs_list.set_item_metadata(ix, job)
		active_jobs_list.set_item_tooltip(ix, job.info())


func update_workers_list() -> void:
	print("updating workers..")
	workers_list.clear()
	for worker in Workers.workers:
		var ix := workers_list.add_item(worker.name)
		workers_list.set_item_tooltip(ix, worker.info(Input.is_action_pressed("ctrl")))
