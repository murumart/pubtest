class_name MGCharacter extends CharacterBody2D

const AR = ActorComponent.ActionResult

signal act_requested(who: MGCharacter)
signal act_finished(who: MGCharacter)

signal move_requested(who: MGCharacter, to: Vector2)

@export var actor_component: Node

var _time := 1.0


func _ready() -> void:
	assert(is_instance_valid(actor_component), "no actor component set")
	assert(actor_component.has_method("act"), "actor component node faulty")


func decrease_time(amount: float) -> void:
	_time -= absf(amount)
	if _time <= 0:
		act_requested.emit(self)


func start_act() -> void:
	var result: AR = await actor_component.act()
	_time = result.time

	match result.type:
		AR.TYPE_MOVE:
			move_requested.emit(self, result.target_pos)

	finish_act()


func finish_act() -> void:
	act_finished.emit(self)
