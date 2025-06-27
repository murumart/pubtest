const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const Jobs = preload("res://scenes/colony/jobs.gd")
const Job = Jobs.Job
const Resources = preload("res://scenes/colony/resources.gd")
const Workers = preload("res://scenes/colony/workers.gd")
const ColonyTile = preload("res://scenes/colony/world/colony_tile.gd")
const TileTypes = ColonyTile.TileTypes
const Civs = preload("res://scenes/colony/civs.gd")

static func select_job(sp: SelectionPopup, aval_jobs: Dictionary) -> Job:
	var j = await sp.pop(
		sp.Parameters.new()
			.set_inputs_d(aval_jobs)
			.set_tooltips(aval_jobs.values().map(func(j: Jobs.Job) -> String: return j.info()))
			.set_title("select job")
			.set_result_callable(sp.wait_item_result)
			.set_ok_cancel(false, true))
	var job: Jobs.Job = j if not j is int else null
	if job != null:
		job = job.can_register()
		if job is not Jobs.DoableJob:
			print("jobv error: " + job.title)
			return job
		Jobs.add(job)
		print("added jop to " + str(job.map_tile))
		return job
	return null


static func get_tree_jobs(pos: Vector2i, ctile_pos: Vector2i) -> Dictionary[String, Job]:
	var d: Dictionary[String, Job]

	if true:
		var job := Jobs.mk("chop tree").csttime(60).cstloc(ctile_pos, pos)
		job.rewards = {"wood": 10}
		job.energy_usage = 35
		job.skill_reductions = {"woodcutting": 4}
		job.skill_rewards = {"woodcutting": 1}
		job.tools_required = {"axe": 1}
		job.finished = func() -> void:
			ColonyTile.replace_tile(TileTypes.TREE, TileTypes.GRASS, pos, ctile_pos)
			Civs.civs[1].change_standing(0, -1)
		d["chop tree"] = job
	if true:
		var job := Jobs.mk("gather seeds").csttime(60 * 1.6).cstloc(ctile_pos, pos)
		job.rewards = {"seedling": 3}
		job.energy_usage = 12
		job.skill_reductions = {"arborist": 5}
		job.skill_rewards = {"arborist": 2}
		job.tools_required = {"scissors": 1}
		d["gather seeds"] = job
	if true:
		var job := Jobs.mk("hug tree").csttime(1).cstloc(ctile_pos, pos)
		job.worker_limit = 1
		job.energy_usage = 1
		job.rewards = {"love": 1}
		job.skill_rewards = {"loving": 1}
		d["hug tree"] = job

	return d


static func get_pebble_jobs(pos: Vector2i, ctile_pos: Vector2i) -> Dictionary[String, Job]:
	var d: Dictionary[String, Job]

	if true:
		var job := Jobs.mk("gather pebbles").csttime(30).cstloc(ctile_pos, pos)
		job.energy_usage = 20
		job.rewards = {"hard rock": 2}
		job.skill_reductions = {"gathering": 5}
		job.skill_rewards = {"gathering": 1}
		job.finished = func() -> void:
			if randf() < 0.5:
				ColonyTile.replace_tile(TileTypes.PEBBLES, TileTypes.GRASS, pos, ctile_pos)
		d["gather pebbles"] = job

	return d


static func get_building_jobs(pos: Vector2i, ctile_pos: Vector2i) -> Dictionary[String, Job]:
	var d: Dictionary[String, Job]

	if true:
		var job := Jobs.mk("build campfire").csttime(60 * 1.2).cstloc(ctile_pos, pos)
		job.energy_usage = 35
		job.input_resources = {"wood": 8, "hard rock": 3}
		job.skill_reductions = {"construction": 10}
		job.skill_rewards = {"construction": 1}
		job.finished = ColonyTile.set_tile.bind(ctile_pos, pos, TileTypes.CAMPFIRE)
		d["build campfire"] = job
	if true:
		var job := Jobs.mk("build house").csttime(60 * 14).cstloc(ctile_pos, pos)
		job.energy_usage = 180
		job.input_resources = {"wood": 30, "hard rock": 5}
		job.skill_reductions = {"construction": 10}
		job.skill_rewards = {"construction": 10}
		job.tools_required = {"axe": 1}
		job.finished = func() -> void:
			ColonyTile.set_tile(ctile_pos, pos, TileTypes.HOUSE)
			Workers.create_residence(ctile_pos, pos, 3)
		d["build house"] = job

	return d


static func get_cooking_jobs(pos: Vector2i, ctile_pos: Vector2i) -> Dictionary[String, Job]:
	var d: Dictionary[String, Job]

	if true:
		var job := Jobs.mk("cook fish").csttime(30).cstloc(ctile_pos, pos)
		job.energy_usage = 15
		job.input_resources = {"fish": 5} # TODO tags that can use any available resource
		job.rewards = {"food": 5}
		job.skill_reductions = {"cooking": 2}
		job.skill_rewards = {"cooking": 1}
		d["cook fish"] = job

	return d


static func get_fishing_jobs(pos: Vector2i, ctile_pos: Vector2i) -> Dictionary[String, Job]:
	var d: Dictionary[String, Job]

	if true:
		var job := Jobs.mk("fish barehanded").csttime(30).cstloc(ctile_pos, pos)
		job.energy_usage = 35
		job.rewards = {"fish": 1}
		job.skill_reductions = {"fishing": 1}
		job.skill_rewards = {"fishing": 5}
		d["fish barehanded"] = job

	if true:
		var job := Jobs.mk("fish with spears").csttime(30).cstloc(ctile_pos, pos)
		job.energy_usage = 30
		job.rewards = {"fish": 2}
		job.tools_required = {"spear": 1}
		job.skill_reductions = {"fishing": 2}
		job.skill_rewards = {"fishing": 2}
		d["fish with spears"] = job

	if true:
		var job := Jobs.mk("fish with pole").csttime(30).cstloc(ctile_pos, pos)
		job.energy_usage = 15
		job.rewards = {"fish": 5}
		job.tools_required = {"fishing pole": 1}
		job.skill_reductions = {"fishing": 5}
		job.skill_rewards = {"fishing": 1}
		d["fish with pole"] = job

	return d


static func get_residence_jobs(pos: Vector2i, ctile_pos: Vector2i) -> Dictionary[String, Job]:
	var d: Dictionary[String, Job]

	var residence := Workers.residences.get(ctile_pos * ColonyTile.SIZE + pos, null) as Workers.Residence
	assert(residence != null)
	if residence.residents.size() < residence.capacity:
		var job := Jobs.mk("move resident here").csttime(1).cstloc(ctile_pos, pos)
		job.energy_usage = 1
		job.worker_limit = 1
		job.skill_reductions = {"moving": 2}
		job.skill_rewards = {"moving": 2}
		job.finished = func() -> void:
			var worker := Workers.workers[job.workers[0]]
			Workers.move_residence(worker, worker.residence, residence)
		d["move resident here"] = job

	return d
