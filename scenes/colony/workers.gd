const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const Jobs = preload("res://scenes/colony/jobs.gd")
const Resources = preload("res://scenes/colony/resources.gd")
const ColonyTile = preload("res://scenes/colony/world/colony_tile.gd")
const TileTypes = ColonyTile.TileTypes
const ColonyMain = preload("res://scenes/colony/colony_main.gd")

static var workers: Array[Worker]
static var residences: Dictionary[Vector2i, Residence]


static func _static_init() -> void:
	dat.sets(dk.WORKERS, workers)
	dat.sets(dk.RESIDENCES, residences)
	if true:
		var w := Worker.new()
		w.name = Worker.random_name()
		w.skills = {"woodcutting": 2}
		w.attributes = {"max hp": 10, "max energy": 100}
		w.hp = w.attributes["max hp"]
		w.energy = w.attributes["max energy"]
		workers.append(w)
	if true:
		var w := Worker.new()
		w.name = Worker.random_name()
		w.skills = {"crafting": 2}
		w.attributes = {"max hp": 10, "max energy": 80}
		w.hp = w.attributes["max hp"]
		w.energy = w.attributes["max energy"]
		workers.append(w)
	if true:
		var w := Worker.new()
		w.name = Worker.random_name()
		w.skills = {"franking": 4}
		w.attributes = {"max hp": 4, "max energy": 100}
		w.hp = w.attributes["max hp"]
		w.energy = w.attributes["max energy"]
		workers.append(w)


static func get_available_ixes() -> PackedInt64Array:
	var ixes := PackedInt64Array()

	for i in workers.size():
		if workers[i].on_jobs.is_empty() and not workers[i].dead and workers[i].energy > 0:
			ixes.append(i)

	return ixes


static func worker_die(ix: int) -> void:
	var worker := workers[ix]
	worker.residence.residents.erase(worker)
	for j in worker.on_jobs:
		j.remove_worker(ix)
	worker.hp = -1.0
	ColonyMain.loge("worker " + worker.name + " is dead.")


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
				ColonyMain.loge("worker " + worker.name + " is starving!")
				worker.hp -= amt / 50.0
				if worker.hp <= 0.0:
					ColonyMain.loge("worker " + worker.name + " starved to death!")
					worker_die(i)
		# resting
		if worker.on_jobs.is_empty():
			worker.energy = clampi(roundi(worker.energy + amt * 0.025), 0, worker.attributes.get("max energy"))


static func increment_day() -> void:
	for w in workers:
		var replenishment := 0.5
		var living_tile: Vector2i = ColonyTile.get_tile(w.living_ctile, w.living_maptile)
		match living_tile:
			TileTypes.HOUSE: replenishment = 0.75
			TileTypes.TOWN_CENTRE: replenishment = 0.7
		w.energy = mini(w.attributes["max energy"], int(w.energy + w.attributes["max energy"] * replenishment))
	for r in residences:
		var residence := residences[r]
		if residence.capacity > residence.residents.size() and randf() < 0.75:
			var w := Worker.new()
			w.name = Worker.random_name()

			w.skills = {}
			const SKILLZ := [&"woodcutting", &"mining", &"cooking", &"crafting", &"fishing", &"construction"]
			for i in randi_range(1, 5):
				var skilln: StringName = SKILLZ.pick_random()
				w.skills[skilln] = maxi(1, randfn(2, 4))

			w.attributes = {"max hp": int(randfn(10, 2)), "max energy": int(randfn(100, 7))}
			w.hp = w.attributes["max hp"]
			w.energy = w.attributes["max energy"]
			if randf() < 0.25:
				w.attributes["feeding time"] = maxi(1, randfn(18 * 60, 6 * 60))
			if randf() < 0.25:
				w.attributes["ravenosity"] = maxi(1, randfn(1, 2))
			workers.append(w)
			ColonyMain.loge("worker " + w.name + " joined the colony")
			move_residence(w, null, residence)
			return
	if workers.all(func(a: Worker) -> bool: return not is_instance_valid(a) or a.dead):
		LTS.change_scene_to("res://scenes/colony/game_over.tscn")


static func create_residence(ctile: Vector2i, maptile: Vector2i, capacity: int) -> Residence:
	var ix := ctile * ColonyTile.SIZE + maptile
	assert(ix not in residences)
	var r := Residence.new()
	r.ctile = ctile
	r.maptile = maptile
	r.capacity = capacity
	residences[ix] = r
	return r


static func remove_residence(ctile: Vector2i, maptile: Vector2i) -> void:
	var ix := ctile * ColonyTile.SIZE + maptile
	assert(residences[ix].residents.is_empty())
	residences.erase(ix)


static func move_residence(target: Worker, from: Residence, to: Residence) -> void:
	target.living_ctile = ColonyTile.WCOORD
	target.living_maptile = ColonyTile.WCOORD
	if from != null:
		assert(target in from.residents)
		from.residents.erase(target)
	assert(to.residents.size() < to.capacity)
	to.residents.append(target)
	target.residence = to
	target.living_ctile = to.ctile
	target.living_maptile = to.maptile
	ColonyMain.loge("worker " + target.name + " moved from " + str(from) + " to " + str(to))


class Worker:
	var name: String
	var skills: Dictionary[StringName, int]
	var experience: Dictionary[StringName, float]
	var attributes: Dictionary[StringName, int]
	var energy: int
	var hp: float
	var since_last_eat: int
	var living_ctile: Vector2i = Vector2i.ONE * -1
	var living_maptile: Vector2i = Vector2i.ONE * -1
	var on_jobs: Array[Jobs.Job]
	var residence: Residence
	var dead: bool:
		get:
			return hp <= 0.0


	func gain_xp(skill: StringName, amt: float) -> void:
		experience.set(skill, experience.get(skill, 0.0) + amt)


	func try_levelup() -> void:
		for skill in experience:
			while experience[skill] >= skills.get(skill, 0) * 10:
				experience[skill] -= skills.get(skill, 0) * 10
				skills[skill] = skills.get(skill, 0) + 1
				ColonyMain.loge("worker " + name + " leveled up " + skill + " to " + str(skills[skill]))


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
			txt += "\nexperience:"
			sorted = experience.keys()
			sorted.sort_custom(func(k: String, l: String) -> bool: return experience[k] > experience[l])
			for i in sorted.size():
				txt += "\n    " + sorted[i] + ": " + str(experience[sorted[i]])

			txt += "\nattributes:"
			for at in attributes:
				txt += "\n    " + at + ": " + str(attributes[at])
			txt += "\n%s minutes since last ate" % since_last_eat
			txt += "\nliving at %s in %s" % [living_maptile, living_ctile]
		return txt


	func title() -> String:
		var t := name
		if dead:
			t += " (dead)"
		else:
			t += " e(%s/%s)" % [energy, attributes["max energy"]]
		return t


	static func random_name() -> String:
		const syls := [
			["gla", "gun", "ger", "gre", "fra", "ble", "a", "a", "a", "a", "e", "e", "e", "i", "i", "i", "o", "o", "o", "ban", "sla", "san", "gua", "pa", "gar", "", "", "glee", "kur"],
			["bun", "gun", "lun", "sun", "sus", "lus", "ala", "ele", "lele", "bolo", "olo", "olon", "lol", "l", "kin", "g", "wa"],
			["gus", "", "sus", "mets", "gus", "gus", "g"]
		]
		var n: String = syls[0].pick_random() + syls[1].pick_random() + syls[2].pick_random()
		n[0] = n[0].to_upper()
		return n


class Residence:
	var ctile: Vector2i
	var maptile: Vector2i
	var capacity: int
	var residents: Array[Worker]


	func _to_string() -> String:
		return "residence at c%s m%s" % [ctile, maptile]
