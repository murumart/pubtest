class_name MGMoveAction extends MGAction

@export var direction: Vector2i


func get_time_cost() -> int:
	var cost := super()
	if direction.x != 0 and direction.y != 0:
		cost = int(cost * 1.41421)
	return cost


func apply() -> void:
	_bound_character.request_move(self)
	finish_acting()


static func construct(dir: Vector2i) -> MGMoveAction:
	var a := MGMoveAction.new()
	a.direction = dir
	return a
