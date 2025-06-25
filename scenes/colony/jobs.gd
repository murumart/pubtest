const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const ColonyTile = preload("res://scenes/colony/colony_tile.gd")
const TileTypes = ColonyTile.TileTypes
const Resources = preload("res://scenes/colony/resources.gd")
const Workers = preload("res://scenes/colony/workers.gd")
const Jobs = preload("res://scenes/colony/jobs.gd")
const ColonyMain = preload("res://scenes/colony/colony_main.gd")

static var jobs: Array[DoableJob]


static func _static_init() -> void:
	dat.sets(dk.JOBS, jobs)
	jobs = dat.gets(dk.JOBS)
	print("jobs initted")


static func mk(title: String = "") -> Job:
	var j := DoableJob.new()
	j.title = title
	return j


static func err(title: String) -> JobError:
	var j := JobError.new()
	j.title = title
	return j


static func add(job: DoableJob) -> int:
	for inp in job.input_resources:
		assert(Resources.resources.get(inp, 0) >= job.input_resources[inp])
		Resources.incri(inp, -job.input_resources[inp])
	for inp in job.tools_required:
		assert(Resources.resources.get(inp, 0) >= job.tools_required[inp])
		Resources.incri(inp, -job.tools_required[inp])
	jobs.append(job)
	job.registred = true
	return jobs.size() - 1


static func get_job(id: int) -> Job:
	return jobs[id]


static func cancel_job(id: int) -> void:
	jobs[id].registred = false
	jobs[id].return_materials()
	jobs[id].return_tools()
	jobs[id] = null


static func cancel_job_j(job: Job) -> void:
	var f := jobs.find(job)
	assert(f >= 0)
	cancel_job(f)


static func assign_to_job(worker_: int, job_: Variant) -> void:
	var job: DoableJob

	if job_ is int:
		job = jobs[job_]
	elif job_ is DoableJob:
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

		var of_full := maxf(0.0, mini(time_req, job.used_time + amt) - job.used_time) / float(time_req)
		#print("we passed %s mins of time on job taking %s minutes (%s minutes done already before this), which is %s%% of its full time required." % [amt, time_req, job.used_time, of_full * 100])
		var useful_workers := job.workers.size()

		for w in job.workers:
			var worker := Workers.workers[w]
			if worker.energy <= 0:
				ColonyMain.loge("worker " + worker.name + " won't do work becasue too tired baby.")
				useful_workers -= 1
				continue

			var enuse := job.get_energy_usage(worker) / useful_workers
			worker.energy = maxi(0, worker.energy - enuse * of_full)

			for sp in job.skill_rewards:
				worker.gain_xp(sp, job.skill_rewards[sp] * of_full)
		if useful_workers <= 0:
			continue
		job.used_time += amt
		if job.used_time >= time_req:
			job.finish()
			jobs[i] = null


class Job:
	var finished: Callable = func() -> void: pass

	var title: String
	# input resources are removed from main resources on creation
	var input_resources: Dictionary[StringName, int]
	var tools_required: Dictionary[StringName, int]
	var rewards: Dictionary[StringName, int]
	## each worker with appropriate skill subtracts their skill lvl * reduction from required time
	var skill_reductions: Dictionary[StringName, float]
	var skill_rewards: Dictionary[StringName, int]
	var used_time: int # increases as job is completed
	var max_time: int
	var energy_usage: int
	var workers: PackedInt64Array
	## job's position on colony map tile, if applicable
	var map_tile: Vector2i = Vector2i.ONE * -1
	## job's world map tile (colony tile) position, if applicable
	var ctile: Vector2i = Vector2i.ONE * -1
	var registred := false


	func can_register() -> Job:
		for inp in input_resources:
			if Resources.resources.get(inp, 0) < input_resources[inp]:
				return Jobs.err("not enough resources")
		for t in tools_required:
			if Resources.resources.get(t, 0) < tools_required[t]:
				return Jobs.err("missing tools")
		return self


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
		used_time = clampi(used_time - get_time_req() / workers.size(), 0, max_time)
		workers.remove_at(ix)
		Workers.workers[id].on_jobs.erase(self)


	func csttime(to: int) -> Job:
		max_time = to
		used_time = 0
		return self


	func cstloc(cpos: Vector2i, mappos: Vector2i) -> Job:
		ctile = cpos
		map_tile = mappos
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
			if worker.energy <= 0:
				continue
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


	func return_tools() -> void:
		for t in tools_required:
			Resources.incri(t, tools_required[t])


	func return_materials() -> void:
		for m in input_resources:
			Resources.incri(m, input_resources[m])


	func shortinfo() -> String:
		var txt := "job" if not title else title
		if map_tile != Vector2i.ONE * -1:
			txt += " at " + str(map_tile)
		if not workers.is_empty():
			txt += " (%s/%s)" % [used_time, get_time_req()]
		return txt


	func info(extra: bool = false) -> String:
		var txt := title + " "
		if registred:
			var trdc := get_time_req()
			txt += "completion: "
			if workers.is_empty():
				txt += "no workers assigned"
			else:
				txt += "%s/%s" % [used_time, trdc]
				txt += "\nworkers: "
				for w in workers:
					txt += Workers.workers[w].name
					if w != workers[-1]: txt += ", "

		if not tools_required.is_empty():
			txt += "\nrequired tools:"
			for tool in tools_required:
				var amt := tools_required[tool]
				txt += "\n    " + tool
				if amt > 1:
					txt += ": " + str(amt)
		if not input_resources.is_empty():
			txt += "\ninput resources:"
			for ir in input_resources:
				txt += "\n    " + ir + ": " + str(input_resources[ir])
		if not rewards.is_empty():
			txt += "\nrewards:"
			for rw in rewards:
				txt += "\n    " + rw + ": " + str(rewards[rw])
		if extra:
			txt += "\nbase energy usage: " + str(energy_usage)
			if not skill_reductions.is_empty():
				txt += "\nskill reductions:"
				for rw in skill_reductions:
					txt += "\n    " + rw + ": " + str(skill_reductions[rw])
			if not skill_rewards.is_empty():
				txt += "\nskill rewards:"
				for rw in skill_rewards:
					txt += "\n    " + rw + ": " + str(skill_rewards[rw])
		return txt


	func finish() -> void:
		assert(false, "Unimplemented!")


class JobError extends Job:

	func finish() -> void:
		assert(false, "Error! " + title)


class DoableJob extends Job:

	func finish() -> void:
		finished.call()
		for rew in rewards:
			Resources.incri(rew, rewards[rew])
		for w in workers:
			var worker := Workers.workers[w]
			worker.try_levelup()
			#worker.energy -= roundi(get_energy_usage(worker) / float(workers.size()))
		return_tools()
		free_workers()
