class_name MGCharacter extends CharacterBody2D

signal act_requested(who: MGCharacter)
signal act_finished(who: MGCharacter)

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
	var result: ActorComponent.ActionResult = await actor_component.act()
	_time = result.time
	finish_act()


func finish_act() -> void:
	act_finished.emit(self)
