const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const Jobs = preload("res://scenes/colony/jobs.gd")
const Workers = preload("res://scenes/colony/workers.gd")

const DAY_TIME := 60 * 18

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


static func _static_init() -> void:
	resources = get_data_resources()
	time = DAY_TIME
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


static func get_time_str() -> String:
	var hours := (DAY_TIME - time) / 60 + 6
	var minutes := (60 - time % 60) % 60
	return str(hours) + ":" + str(minutes).lpad(2, "0")
