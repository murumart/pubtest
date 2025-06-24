const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const Jobs = preload("res://scenes/colony/jobs.gd")
const Workers = preload("res://scenes/colony/workers.gd")

static var resources: Dictionary[StringName, int]
static var time: int:
	set(to):
		dat.sets(dk.TIME, to)
	get:
		return dat.gets(dk.TIME)


static func _static_init() -> void:
	resources = get_data_resources()
	incri("food", 30)


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
