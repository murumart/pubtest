extends Control

const Workers = preload("res://scenes/colony/workers.gd")

const ColonyTile = preload("res://scenes/colony/world/colony_tile.gd")
const TileTypes = ColonyTile.TileTypes
const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const res = preload("res://scenes/colony/resources.gd")
const Jobs = preload("res://scenes/colony/jobs.gd")
const Resources = preload("res://scenes/colony/resources.gd")

signal time_pass_request(amt: int)
signal job_removal_request(job: Jobs.Job)

@export var cursor: Node2D
@export var tile_info_label: Label
@export var resource_info_label: Label
@export var time_info_label: Label
@export var active_jobs_list: ItemList
@export var workers_list: ItemList


func _ready() -> void:
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
	%MandateButton.pressed.connect(func():
		var wl := $MandateButton/PanelContainer
		wl.visible = !wl.visible
		if wl.visible:
			mandate_mandate()
	)
	active_jobs_list.item_clicked.connect(func(ix: int, __1, __2):
		local_job_worker_adjust(active_jobs_list.get_item_metadata(ix))
	)


func local_job_worker_adjust(job: Jobs.Job) -> void:
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

	var most_useful_skills := job.skill_reductions.keys()
	most_useful_skills.sort_custom(func(a: StringName, b: StringName) -> bool:
		return job.skill_reductions[a] > job.skill_reductions[b]
	)
	var most_useful_skill: StringName = most_useful_skills[0] if not most_useful_skills.is_empty() else &""
	print("jop most useful skill: ", most_useful_skill)

	if choice == 0:
		var worker_fits := job.worker_limit < 0 or job.worker_limit > job.workers.size()
		if not worker_fits:
			await sp.pop(sp.Parameters.new()
				.set_title("Job has enough workers assigned")
				.set_inputs([], [])
				.set_ok_cancel(true, false)
				.set_result_callable(sp.wait_item_result)
			)
			return
		var available_workers := Array(Workers.get_available_ixes())
		if most_useful_skill:
			available_workers.sort_custom(func(a: int, b: int) -> bool:
				return Workers.workers[a].skills.get(most_useful_skill, 0) > Workers.workers[b].skills.get(most_useful_skill, 0)
			)
		var worker: int = await sp.pop(sp.Parameters.new()
			.set_title("add worker" + ("" if not most_useful_skill else " (" + most_useful_skill + ")"))
			.set_inputs(Array(available_workers).map(func(a: int) -> String:
				return Workers.workers[a].title()), available_workers)
			.set_tooltips(Array(available_workers).map(func(a: int) -> String:
				return Workers.workers[a].info(false)))
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
				return Workers.workers[a].title()), Array(job.workers))
			.set_tooltips(Array(job.workers).map(func(a: int) -> String:
				return Workers.workers[a].info(false)))
			.set_result_callable(sp.wait_item_result)
			.set_ok_cancel(false, true)
		)
		if worker >= 0:
			job.remove_worker(worker)
			print("removed worker")
	elif choice == 2:
		#print("filimng " + str(job) + " for removal btw jobs looks like this: " + str(Jobs.jobs))
		job_removal_request.emit(job)


func update_cursor(tpos: Vector2i, tile: ColonyTile) -> void:
	cursor.global_position = (tpos + tile.SIZE * tile.ctile_pos) * tile.tiles.tile_set.tile_size

	tile_info_label.text = "Tile at " + str(tpos) + " %s" % (tpos + tile.SIZE * tile.ctile_pos)
	tile_info_label.text += "\nType: " + str(TileTypes.find_key(tile.tiles.get_cell_atlas_coords(tpos))).to_lower()
	tile_info_label.text += "\nColony Tile at: " + str(tile.ctile_pos)

	var jobshere := tile.jobs.filter(func(j: Jobs.Job) -> bool:
		return j.ctile == tile.ctile_pos and j.map_tile == tpos)
	if not jobshere.is_empty():
		tile_info_label.text += "\nJobs:"
		for j in jobshere:
			tile_info_label.text += "\n    " + j.shortinfo()

	var workershere: Workers.Residence = Workers.residences.get(tile.ctile_pos * tile.SIZE + tpos, null)
	if workershere != null:
		tile_info_label.text += "\nResidents:"
		for w in workershere.residents:
			tile_info_label.text += "\n    " + w.name


func update_resources() -> void:
	var txt := ""
	for k in res.resources.keys():
		txt += str(k) + ": " + str(res.resources[k]) + "\n"
	resource_info_label.text = txt

	time_info_label.text = "Time: " + str(res.time) + " (%s)" % res.get_time_str() + "\nDay: " + str(res.day)


func update_active_jobs(jobs: Array[Jobs.Job]) -> void:
	active_jobs_list.clear()
	for job in jobs:
		# ignore finished jos
		if job not in Jobs.jobs or not is_instance_valid(job):
			continue
		var ix := active_jobs_list.add_item(job.shortinfo())
		active_jobs_list.set_item_metadata(ix, job)
		active_jobs_list.set_item_tooltip(ix, job.info())


func update_workers_list() -> void:
	print("updating workers..")
	workers_list.clear()
	for worker in Workers.workers:
		var ix := workers_list.add_item(worker.title())
		workers_list.set_item_tooltip(ix, worker.info(Input.is_action_pressed("ctrl")))


func mandate_mandate() -> void:
	var mandate_description: RichTextLabel = $MandateButton/PanelContainer/ScrollContainer/MandateDescription
	var mandate := Resources.mandates.back() as Resources.Mandate
	mandate_description.text = mandate.get_description()
