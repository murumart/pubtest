extends Node2D

const UI := preload("res://scenes/colony/ui.gd")
const Cam := preload("res://scenes/colony/movecamera.gd")
const Job := preload("res://scenes/colony/job.gd")
const Worker := preload("res://scenes/colony/worker.gd")
const Place := preload("res://scenes/colony/place.gd")

const JobButton := preload("res://scenes/colony/job_button.gd")

@export var camera: Cam
@export var ui: UI
@export var tiles: TileMapLayer
@export var places_root: Node2D

var resources: Dictionary[StringName, int] = {}
var time: float = 18
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


func place_place(pos: Vector2i, place: Place) -> void:
	assert(grid.get(pos) == null, "grid position occupied")
	grid[pos] = place
	places_root.add_child(place)
	place.position = Vector2(pos) * 16


func clean_places() -> void:
	for k: Vector2i in grid.keys():
		var v := grid[k]
		if not is_instance_valid(v) or v == null:
			grid.erase(k)


func place_job(pos: Vector2i, job: Job) -> void:
	var place := grid[pos]
	assert(not place.has_active_job(), "job position occupied")
	place.set_active_job(job)
	var button := JobButton.instantiate()
	button.init(job, self, complete_job.bind(job))
	add_child(button)
	button.position = Vector2(pos) * 16
	job.set_meta("button", button)


func complete_job(job: Job) -> Error:
	if not job.can_complete(resources, time): return FAILED
	time = job.complete(resources, time)
	job.reward(resources)
	clean_places()
	return OK


func complete_jobs() -> void:
	clean_places()
	for pos in grid:
		var place := grid[pos]
		if not place.has_active_job(): continue
		var job := place.get_active_job()
		if complete_job(job) != OK: continue
		if job.has_meta("button"):
			(job.get_meta("button") as JobButton).queue_free()
