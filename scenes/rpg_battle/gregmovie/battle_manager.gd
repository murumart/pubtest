extends Node

enum State {
	WAITING,
	ACTING
}

var state: State:
	set(to):
		state = to
		print("battle state is now ", State.find_key(to))
		match to:
			State.WAITING:
				set_process(true)
			State.ACTING:
				set_process(false)

@export var grid: MGActorGrid


func _ready() -> void:
	await grid.ready
	for chara: MGCharacter in grid.get_characters():
		chara.act_requested.connect(_on_act_requested)
	state = State.WAITING


func _process(delta: float) -> void:
	for chara: MGCharacter in grid.get_characters():
		chara.decrease_time(delta)


func _on_act_requested(who: MGCharacter) -> void:
	state = State.ACTING
	who.act_finished.connect(_on_act_finished, CONNECT_ONE_SHOT)
	who.start_act()


func _on_act_finished(who: MGCharacter) -> void:
	state = State.WAITING
