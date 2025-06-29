const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const Jobs = preload("res://scenes/colony/jobs.gd")
const Workers = preload("res://scenes/colony/workers.gd")
const ColonyMain = preload("res://scenes/colony/colony_main.gd")
const Resources = preload("res://scenes/colony/resources.gd")
const Civs = preload("res://scenes/colony/civs.gd")

const DAY_TIME := 60 * 18
const MANDATE_EVERY := 7

static var resources: Dictionary[StringName, int]
static var time: int:
	set(to):
		dat.sets(dk.TIME, to)
	get:
		return dat.gets(dk.TIME)

static var day: int:
	set(to):
		dat.sets(dk.DAY, to)
	get:
		return dat.gets(dk.DAY, 0)

static var mandates: Array[Mandate]


static func _static_init() -> void:
	resources = get_data_resources()
	time = DAY_TIME
	day = 1
	if true:
		var m := Mandate.new()
		m.required_resources = {"wood": 200}
		m.reward_resources = {"pickaxe": 1, "axe": 1}
		mandates.append(m)
	ColonyMain.loge.call_deferred.bind("You have %s days to fulfill a mandate." % MANDATE_EVERY)
	incri("food", 30)
	incri("axe", 1)


static func get_data_resources() -> Dictionary[StringName, int]:
	return dat.gets(dk.RESOURCES)


static func incri(name: StringName, amt: int = 1) -> void:
	if name not in resources:
		resources[name] = amt
	else:
		resources[name] += amt


static func pass_time(amt: int) -> void:
	time -= amt
	Jobs.pass_time(amt)
	Workers.pass_time(amt)
	if time <= 0:
		increment_day()
		time = DAY_TIME + time


static func increment_day() -> void:
	day += 1
	Workers.increment_day()
	ColonyMain.loge("it's a new day (" + str(day) + ")")
	if day % MANDATE_EVERY == 0:
		_mandates()


static func get_time_str() -> String:
	var hours := (DAY_TIME - time) / 60 + 6
	var minutes := (60 - time % 60) % 60
	return str(hours) + ":" + str(minutes).lpad(2, "0")


static func _mandates() -> void:
	var mandate := mandates[mandates.size() - 1]
	if not mandate.can_fulfill():
		ColonyMain.loge("You failed to fulfill a mandate.")
		Civs.civs[0].change_standing(0, -6)
	else:
		mandate.fulfill()
		ColonyMain.loge("A mandate was fulfilled.")
		Civs.civs[0].change_standing(0, 5)
	match day:
		7:
			var m := Mandate.new()
			m.required_resources = {"hard rock": 200}
			m.reward_resources = {"fishing pole": 2}
			mandates.append(m)
		14:
			var m := Mandate.new()
			m.required_resources = {"fish": 300}
			m.reward_resources = {"fishing pole": 2}
			mandates.append(m)
		21:
			assert(false)
		28:
			assert(false)




class Mandate:
	var required_resources: Dictionary[StringName, int]
	var reward_resources: Dictionary[StringName, int]


	func can_fulfill() -> bool:
		for r in required_resources:
			if Resources.resources.get(r, 0) < required_resources[r]:
				return false
		return true


	func fulfill() -> void:
		for r in required_resources:
			Resources.incri(r, -required_resources[r])
		for r in reward_resources:
			Resources.incri(r, reward_resources[r])


	func get_description() -> String:
		var txt := "By the decree of the holy ruler Moly, your colony must provide:"
		for r in required_resources:
			txt += "\n- " + r + " x" + str(required_resources[r])
		txt += "\nafter which you will be rewarded with:"
		for r in reward_resources:
			txt += "\n- " + r + " x" + str(reward_resources[r])
		var timeleft := 7 - Resources.day % 7
		txt += "\n" + str(timeleft) + " days left."

		return txt
