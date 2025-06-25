const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const Jobs = preload("res://scenes/colony/jobs.gd")
const Resources = preload("res://scenes/colony/resources.gd")
const ColonyTile = preload("res://scenes/colony/colony_tile.gd")
const TileTypes = ColonyTile.TileTypes

static var workers: Array[Worker] = []


static func _static_init() -> void:
	dat.sets(dk.WORKERS, workers)
	if true:
		var w := Worker.new()
		w.name = "jaalgus"
		w.skills = {"woodcutting": 2}
		w.attributes = {"max hp": 10, "max energy": 100}
		w.hp = w.attributes["max hp"]
		w.energy = w.attributes["max energy"]
		workers.append(w)
	if true:
		var w := Worker.new()
		w.name = "gangus"
		w.skills = {"crafting": 2}
		w.attributes = {"max hp": 10, "max energy": 80}
		w.hp = w.attributes["max hp"]
		w.energy = w.attributes["max energy"]
		workers.append(w)
	if true:
		var w := Worker.new()
		w.name = "franking"
		w.skills = {"franking": 4}
		w.attributes = {"max hp": 4, "max energy": 100}
		w.hp = w.attributes["max hp"]
		w.energy = w.attributes["max energy"]
		workers.append(w)


static func get_available_ixes() -> PackedInt64Array:
	var ixes := PackedInt64Array()

	for i in workers.size():
		if workers[i].on_jobs.is_empty():
			ixes.append(i)

	return ixes


static func pass_time(amt: int) -> void:
	for i in range(workers.size() - 1, -1, -1):
		var worker := workers[i]
		if worker.hp <= 0:
			continue
		worker.since_last_eat += amt
		var feeding_time: int = worker.attributes.get("feeding time", 60 * 18)
		if worker.since_last_eat >= feeding_time:
			var ravenosity: int = worker.attributes.get("ravenosity", 1)
			if Resources.resources.get("food", 0) >= ravenosity:
				Resources.incri("food", -ravenosity)
				worker.since_last_eat = 0
			elif worker.since_last_eat > feeding_time * 2:
				worker.hp -= amt / 50.0


static func increment_day() -> void:
	for w in workers:
		var replenishment := 0.5
		var living_tile: Vector2i = ColonyTile.get_tile(w.living_ctile, w.living_maptile)
		match living_tile:
			TileTypes.HOUSE: replenishment = 0.75
			TileTypes.TOWN_CENTRE: replenishment = 0.7
		w.energy = mini(w.attributes["max energy"], w.energy + w.attributes["max energy"] * replenishment)


class Worker:
	var name: String
	var skills: Dictionary[String, int]
	var experience: Dictionary[String, int]
	var attributes: Dictionary[String, int]
	var energy: int
	var hp: float
	var since_last_eat: int
	var living_ctile: Vector2i = Vector2i.ONE * -1
	var living_maptile: Vector2i = Vector2i.ONE * -1
	var on_jobs: Array[Jobs.Job]


	func info(extra: bool) -> String:
		var txt := "worker " + name + "\nhp: %s/%s" % [snappedf(hp, 0.1), attributes["max hp"]] + "\nenergy: %s/%s" % [energy, attributes["max energy"]]
		txt += "\nworks %s jobs" % on_jobs.size()
		if not extra:
			txt += "\ntop skills:"
			var sorted := skills.keys()
			sorted.sort_custom(func(k: String, l: String) -> bool: return skills[k] > skills[l])
			for i in mini(sorted.size(), 3):
				txt += "\n    " + sorted[i] + ": " + str(skills[sorted[i]])
		elif extra:
			txt += "\nskills:"
			var sorted := skills.keys()
			sorted.sort_custom(func(k: String, l: String) -> bool: return skills[k] > skills[l])
			for i in sorted.size():
				txt += "\n    " + sorted[i] + ": " + str(skills[sorted[i]])

			txt += "\nattributes:"
			for at in attributes:
				txt += "\n    " + at + ": " + str(attributes[at])
			txt += "\n%s minutes since last ate" % since_last_eat
			txt += "\nliving at %s in %s" % [living_maptile, living_ctile]
		return txt
