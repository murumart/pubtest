class_name MGCharacter extends CharacterBody2D

signal act_requested(who: MGCharacter)
signal act_finished(who: MGCharacter)

var _time := 1.0


func decrease_time(amount: float) -> void:
	_time -= absf(amount)
	if _time <= 0:
		act_requested.emit(self)


func start_act() -> void:
	_time = 2


func finish_act() -> void:
	act_finished.emit(self)
