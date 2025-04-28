extends Node2D

const UI := preload("res://scenes/colony/ui.gd")
const Cam := preload("res://scenes/colony/movecamera.gd")
const Job := preload("res://scenes/colony/job.gd")
const Worker := preload("res://scenes/colony/worker.gd")
const Place := preload("res://scenes/colony/place.gd")

@export var camera: Cam
@export var ui: UI
@export var tiles: TileMapLayer
@export var places_root: Node2D

var resources: Dictionary[StringName, int] = {"time": 18}
var jobs: Dictionary[Vector2i, Job]
var workers: Dictionary[Worker, bool]
var grid: Dictionary[Vector2i, Place]


func _ready() -> void:
	ui.job_completion_requested.connect(complete_jobs)
	
	for i in range(-10, 10):
		for j in range(-10, 10):
			if randf() < 0.05:
				place_place(Vector2i(i, j), Place.create_forest())
	
	const alpha = "abcdefghijklmnopqrst"
	for i in 10:
		var n := ""
		for __ in maxi(ceili(randfn(5, 2)), 2):
			n += alpha[randi_range(0, alpha.length() - 1)]
		workers[Worker.create_worker(n)] = true


func _physics_process(_delta: float) -> void:
	mousestuff()
	
	ui.display_resources(resources)
	ui.display_workers(workers)
	draw_jobs()


func mousestuff() -> void:
	var mousepos := get_global_mouse_position()
	var tilepos := tiles.local_to_map(tiles.to_local(mousepos))

	var _err := draw.connect(func() -> void:
		draw_rect(Rect2(tilepos.x * 16, tilepos.y * 16, 16, 16), Color(Color.WHITE, 0.2))
	, CONNECT_ONE_SHOT)
	
	if not is_instance_valid(grid.get(tilepos)):
		grid.erase(tilepos)
	var place: Place = grid.get(tilepos)
	ui.display_place(tilepos, place)
	
	if Input.is_action_just_pressed("click") and not ui.popup.visible:
		if not is_instance_valid(place):
			return
		clicked_place(tilepos, place)
	
	queue_redraw()


func clicked_place(pos: Vector2i, place: Place) -> void:
	place.clicked_on()
	if jobs.has(pos): return
	var selected: Job = await ui.popup.pop(SelectionPopup.Parameters.new()
			.set_inputs(
				place.jobs.keys().map(func(j: Job) -> String: return j._jobname),
				place.jobs.keys())
			.set_title("select job"))
	place_job(pos, selected)
	#print("selected", selected)


func place_place(pos: Vector2i, place: Place) -> void:
	assert(grid.get(pos) == null, "grid position occupied")
	grid[pos] = place
	places_root.add_child(place)
	place.position = Vector2(pos) * 16


func clean_places() -> void:
	var rm := []
	
	for k in grid:
		var v := grid[k]
		if not is_instance_valid(v): rm.append(k)
	
	for k in rm:
		grid.erase(k)


func place_job(pos: Vector2i, job: Job) -> void:
	assert(jobs.get(pos) == null, "job position occupied")
	jobs[pos] = job
	draw_jobs()


func complete_jobs() -> void:
	var rm := []
	
	for job_pos in jobs:
		var job := jobs[job_pos]
		if not job.can_complete(resources): continue
		job.deplete(resources)
		job.reward(resources)
		rm.append(job_pos)
	
	for jp: Vector2i in rm:
		jobs.erase(jp)
	
	clean_places()


func draw_jobs() -> void:
	for jobp in jobs:
		jobs[jobp].draw(self, Vector2(jobp) * 16)
