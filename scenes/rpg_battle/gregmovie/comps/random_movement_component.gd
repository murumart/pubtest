extends MGMoveComponent


func do_move(_grid: MGActorGrid) -> void:
	var dir := Vector2i(randi_range(-1, 1), randi_range(-1, 1))
	var action := MGMoveAction.construct(dir)
	target.request_action(action)
