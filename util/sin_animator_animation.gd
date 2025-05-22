class_name StringAnimatorAnimation extends Resource

enum Algo {
	SIN,
	COS,
}

@export var _min_value: float
@export var _max_value: float = 1.0

@export var _speed: float = 1.0
@export var _algo: Algo

var _run = sin


func init() -> void:
	_run = [sin, cos][int(_algo)]


func get_value(t: float) -> float:
	var vrange := _max_value - _min_value
	return _min_value + (_run.call(t * _speed) * 0.5 + 0.5) * vrange - vrange
