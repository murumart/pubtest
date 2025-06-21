class_name StringAnimatorAnimation extends Resource

static var _ALGOS = [sin, cos]

enum Algo {
	SIN,
	COS,
}

@export var _min_value: float
@export var _max_value: float = 1.0

@export var _speed: float = 1.0
@export var _algo: Algo


func get_value(t: float) -> float:
	var vrange := _max_value - _min_value
	return _min_value + (_ALGOS[_algo].call(t * _speed) * 0.5 + 0.5) * vrange - vrange
