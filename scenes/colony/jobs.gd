const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const ColonyTile = preload("res://scenes/colony/colony_tile.gd")
const TileTypes = ColonyTile.TileTypes
const Resources = preload("res://scenes/colony/resources.gd")

static var jobs: Array[Job]


static func _static_init() -> void:
	dat.sets(dk.JOBS, jobs)
	jobs = dat.gets(dk.JOBS)
	print("jobs initted")


static func mk() -> Job:
	return Job.new()


static func add(job: Job) -> int:
	jobs.append(job)
	return jobs.size() - 1


static func get_job(id: int) -> Job:
	return jobs[id]


static func pass_time(amt: int) -> void:
	for i in range(jobs.size() - 1, -1, -1):
		var job := jobs[i]
		if not is_instance_valid(job) or job == null:
			continue
		job.required_time -= amt
		if job.required_time <= 0:
			job.finished.call()
			job.done()
			jobs[i] = null


class Job:
	var finished: Callable = func() -> void: pass

	# input resources are removed from main resources on creation
	var input_resources: Dictionary[String, int]
	var rewards: Dictionary[String, int]
	var required_time: int # reduces as job is completed
	var max_time: int
	var workers: Array
	## job's position on colony map tile, if applicable
	var map_tile: Vector2i = Vector2i.ONE * -1
	## job's world map tile (colony tile) position, if applicable
	var ctile: Vector2i = Vector2i.ONE * -1


	func done() -> void:
		for rew in rewards:
			Resources.incri(rew, rewards[rew])


	func set_time(to: int) -> Job:
		max_time = to
		required_time = to
		return self


	func calculate_completion() -> float:
		return 1.0 - float(required_time) / float(max_time)


static func replace_tile(
	what: Vector2i,
	with: Vector2i,
	where_close: Vector2i,
	where_far: Vector2i
) -> void:
	if dat.gets(dk.SAVED_CTILES)[where_far][where_close] == what:
		dat.gets(dk.SAVED_CTILES)[where_far][where_close] = with
