extends Sprite2D

const Job := preload("res://scenes/colony/job.gd")

const Place := preload("res://scenes/colony/place.gd")
const Forest := preload("res://scenes/colony/places/forest.gd")

var _jobs: Dictionary[Job, bool]
var _active_job: Job


# virtual overrides

func _ready() -> void:
	centered = false
	texture = get_place_texture()


# construction

static func create_forest() -> Place:
	var f := Forest.new()
	f.add_job(Job.create("chop trees")
			.time_to_complete(5.0)
			.add_reward("wood", 10)
			.set_reward_callback(f.queue_free))
	return f


func add_job(job: Job) -> Place:
	_jobs[job] = true
	return self


# methods

func get_place_texture() -> Texture2D:
	var at := AtlasTexture.new()
	return at


func clicked_on() -> void:
	return


func has_active_job() -> bool:
	return is_instance_valid(_active_job) and _active_job != null


func set_active_job(job: Job) -> void:
	_active_job = job
	job.job_completed.connect(clear_active_job, CONNECT_ONE_SHOT)


func get_active_job() -> Job:
	return _active_job


func clear_active_job() -> void:
	_active_job = null
