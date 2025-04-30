extends Sprite2D

const Job := preload("res://scenes/colony/job.gd")

const Place := preload("res://scenes/colony/place.gd")
const Forest := preload("res://scenes/colony/places/forest.gd")

var jobs: Dictionary[Job, bool]


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
	jobs[job] = true
	return self


# methods

func get_place_texture() -> Texture2D:
	var at := AtlasTexture.new()
	return at


func clicked_on() -> void:
	return
