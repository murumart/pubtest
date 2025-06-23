const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys

static var resources: Dictionary[StringName, int]
static var time: int:
	set(to):
		dat.sets(dk.TIME, to)
	get:
		return dat.gets(dk.TIME)


static func _static_init() -> void:
	resources = get_data_resources()


static func get_data_resources() -> Dictionary[StringName, int]:
	return dat.gets(dk.RESOURCES)


static func incri(name: StringName, amt: int = 1) -> void:
	if name not in resources:
		resources[name] = amt
	else:
		resources[name] += amt
