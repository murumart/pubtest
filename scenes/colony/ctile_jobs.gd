const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const Jobs = preload("res://scenes/colony/jobs.gd")
const Job = Jobs.Job
const Resources = preload("res://scenes/colony/resources.gd")
const Workers = preload("res://scenes/colony/workers.gd")
const ColonyTile = preload("res://scenes/colony/colony_tile.gd")
const TileTypes = ColonyTile.TileTypes


static func select_job(sp: SelectionPopup, aval_jobs: Dictionary) -> Job:
	var j = await sp.pop(
		sp.Parameters.new()
			.set_inputs_d(aval_jobs)
			.set_tooltips(aval_jobs.values().map(func(j: Jobs.Job) -> String: return j.info()))
			.set_title("select job")
			.set_result_callable(sp.wait_item_result)
			.set_ok_cancel(false, true))
	var job: Jobs.Job = j if not j is int else null
	if job != null and job.can_register():
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
		job.finished = Jobs.replace_tile.bind(TileTypes.TREE, TileTypes.GRASS, pos, ctile_pos)
		d["chop tree"] = job
	if true:
		var job := Jobs.mk("gather seeds").csttime(60 * 1.6).cstloc(ctile_pos, pos)
		job.rewards = {"seedling": 3}
		job.energy_usage = 12
		job.skill_reductions = {"arborist": 5}
		job.skill_rewards = {"arborist": 2}
		d["gather seeds"] = job
	if true:
		var job := Jobs.mk("hug tree").csttime(1).cstloc(ctile_pos, pos)
		job.energy_usage = 1
		job.rewards = {"love": 1}
		job.skill_rewards = {"loving": 1}
		d["hug tree"] = job

	return d
