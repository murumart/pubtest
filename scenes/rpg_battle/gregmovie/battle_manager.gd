class_name MGBattleManager extends Node

@export var actor_grid: MGActorGrid
@export var selected_actor: MGCharacter

var _action_queue := {}
var _time := 0

@onready var char_selection: MGCharSelection = $CharSelection


func _ready() -> void:
	_signal_setup()
	_loop()


func _signal_setup() -> void:
	for c in actor_grid.get_characters():
		c.selection_requested.connect(_on_char_selection_requested)
		c.action_requested.connect(_on_char_action_requested)


func _loop() -> void:
	await MGSignalBus.instance.player_input_received
	while true:
		print("proceeding")
		await _proceed()


func _proceed() -> void:
	var actions_this_turn := []
	var _l := 0
	while true:
		_time += 1

		actor_grid.move_actors()

		actions_this_turn = _action_queue.get(_time, [])
		_action_queue.erase(_time)
		if not actions_this_turn.is_empty():
			break

		assert(_l < 100, "Infinite loop!!!!!")
		_l += 1

	for action: MGAction in actions_this_turn:
		print(action)
		action.apply()
		if action.get_character().is_player_controlled():
			print("waiting for him................................................")
			await MGSignalBus.instance.player_input_received


func _on_char_action_requested(mgchar: MGCharacter, action: MGAction) -> void:
	if action is MGMoveAction:
		if not actor_grid.can_move_to(mgchar, action.direction,
				actor_grid.get_grid_position(mgchar)
		):
			mgchar.is_acting = true
			prepare_action(MGSkipAction.new().bind_character(mgchar).set_time_cost(1))
			return
	mgchar.is_acting = true
	prepare_action(action.bind_character(mgchar))


func prepare_action(action: MGAction) -> void:
	var end_time := _time + action.get_time_cost()
	if not end_time in _action_queue:
		_action_queue[end_time] = []
	_action_queue[end_time].append(action)


func _on_char_selection_requested(mgchar: MGCharacter) -> void:
	select(mgchar)


func select(mgchar: MGCharacter) -> void:
	selected_actor = mgchar
	char_selection.open(mgchar)
