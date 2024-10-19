class_name MGPlayerMoveComponent extends MGMoveComponent

const MOVE_LEFT := "move_left"
const MOVE_RIGHT := "move_right"
const MOVE_UP := "move_up"
const MOVE_DOWN := "move_down"
const SKIP_TURN := "skip_turn"


## The player is moved manually
func do_move(_grid: MGActorGrid) -> void:
	return


@warning_ignore("narrowing_conversion")
func _unhandled_input(event: InputEvent) -> void:
	assert(target.is_player_controlled(), "Target isn't player controlled")
	if target.is_acting:
		return
	var direction := Vector2i.ZERO
	if (event is InputEventKey and event.is_pressed()) or event is InputEventJoypadMotion:
		if event.is_action(MOVE_LEFT):
			direction.x -= 1
		if event.is_action(MOVE_RIGHT):
			direction.x += 1
		if event.is_action(MOVE_UP):
			direction.y -= 1
		if event.is_action(MOVE_DOWN):
			direction.y += 1
		if event.is_action(SKIP_TURN):
			print("skipping")
			target.request_action(MGSkipAction.new().set_time_cost(10))
			MGSignalBus.instance.player_input_received.emit()
			return
	if not direction:
		return
	print("creating action")
	var action := MGMoveAction.construct(direction)
	#if not target.is_acting:
	target.request_action(action)
	MGSignalBus.instance.player_input_received.emit()
