class_name MGAction extends Resource

signal finished

@export_storage var _bound_character: MGCharacter
@export var _time_cost: int = 10


func set_time_cost(to: int) -> MGAction:
	_time_cost = to
	return self


func get_time_cost() -> int:
	return _time_cost


func bind_character(mgchar: MGCharacter) -> MGAction:
	_bound_character = mgchar
	return self


func get_character() -> MGCharacter:
	return _bound_character


func finish_acting() -> void:
	_bound_character.is_acting = false
	finished.emit()


func apply() -> void:
	assert(false, "Empty action")


func _to_string() -> String:
	return "Action(charac: " + str(_bound_character) + ", cost: " + str(_time_cost) + ")"
