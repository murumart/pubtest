const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const ColonyTile = preload("res://scenes/colony/colony_tile.gd")
const TileTypes = ColonyTile.TileTypes
const Resources = preload("res://scenes/colony/resources.gd")
const Workers = preload("res://scenes/colony/workers.gd")

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


static func cancel_job(id: int) -> void:
	jobs[id] = null


static func cancel_job_j(job: Job) -> void:
	var f := jobs.find(job)
	assert(f >= 0)
	cancel_job(f)


static func assign_to_job(worker_: int, job_: Variant) -> void:
	var job: Job

	if job_ is int:
		job = jobs[job_]
	elif job_ is Job:
		job = job_
	else: assert(false, "invalid job")

	job.workers.append(worker_)
	Workers.workers[worker_].on_jobs.append(job)


static func pass_time(amt: int) -> void:
	for i in range(jobs.size() - 1, -1, -1):
		var job := jobs[i]
		if not is_instance_valid(job) or job == null:
			continue
		var time_req := job.get_time_req()
		if time_req == -1:
			continue
		job.used_time += amt
		if job.used_time >= time_req:
			job.finish()
			jobs[i] = null


class Job:
	var finished: Callable = func() -> void: pass

	# input resources are removed from main resources on creation
	var input_resources: Dictionary[String, int]
	var rewards: Dictionary[String, int]
	var skill_reductions: Dictionary[String, float]
	var used_time: int # increases as job is completed
	var max_time: int
	var energy_usage: int
	var workers: PackedInt64Array
	## job's position on colony map tile, if applicable
	var map_tile: Vector2i = Vector2i.ONE * -1
	## job's world map tile (colony tile) position, if applicable
	var ctile: Vector2i = Vector2i.ONE * -1


	func finish() -> void:
		finished.call()
		for rew in rewards:
			Resources.incri(rew, rewards[rew])
		for w in workers:
			var worker := Workers.workers[w]
			worker.energy -= get_energy_usage(worker)
		free_workers()


	func cancel() -> void:
		for inp in input_resources:
			Resources.incri(inp, input_resources[inp])
		free_workers()


	func free_workers() -> void:
		for w in workers:
			var worker := Workers.workers[w]
			worker.on_jobs.erase(self)


	func remove_worker(id: int) -> void:
		var ix := workers.find(id)
		workers.remove_at(ix)
		Workers.workers[id].on_jobs.erase(self)


	func set_time(to: int) -> Job:
		max_time = to
		used_time = 0
		return self


	func get_time_req() -> int:
		if workers.is_empty():
			return -1
		for res in input_resources:
			if Resources.resources.get(res, 0) < input_resources[res]:
				return -1

		var reduction := 0.0
		for w in workers:
			var worker := Workers.workers[w]
			var r := 2.0
			for sk in skill_reductions:
				r += worker.skills.get(sk, 0) * skill_reductions[sk]

			reduction += r
		return maxi(1, roundi(max_time - reduction))


	func get_energy_usage(w: Workers.Worker) -> int:
		var reduction := 0.0
		for sk in skill_reductions:
			reduction += w.skills.get(sk, 0) * skill_reductions[sk] * 0.5
		return maxi(1, roundi(energy_usage - reduction))


	func info(extra: bool = false) -> String:
		var txt := ""
		var trdc := get_time_req()
		txt += "completion: "
		if workers.is_empty():
			txt += "no workers assigned"
		else:
			txt += "%s/%s" % [trdc - used_time, trdc]
			txt += "\nworkers: "
			for w in workers:
				txt += Workers.workers[w].name
				if w != workers[-1]: txt += ", "

		if not rewards.is_empty():
			txt += "\nrewards:"
			for rw in rewards:
				txt += "\n    " + rw + ": " + str(rewards[rw])
		if not input_resources.is_empty():
			txt += "\ninput resources:"
			for ir in input_resources:
				txt += "\n    " + ir + ": " + str(input_resources[ir])
		return txt


static func replace_tile(
	what: Vector2i,
	with: Vector2i,
	where_close: Vector2i,
	where_far: Vector2i
) -> void:
	if dat.gets(dk.SAVED_CTILES)[where_far][where_close] == what:
		dat.gets(dk.SAVED_CTILES)[where_far][where_close] = with
