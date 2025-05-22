class_name SinAnimator extends Node

static var _AGGREGATES := [
	Aggregate.new((func (a: float, n: float) -> float: return a + n), 0.0),
	Aggregate.new((func (a: float, n: float) -> float: return a - n), 0.0),
	Aggregate.new((func (a: float, n: float) -> float: return a * n), 1.0),
	Aggregate.new((func (a: float, n: float) -> float: return a / n), 1.0),
	Aggregate.new((func (a: float, n: float) -> float: return a * n), 1.0),
]

enum Aggre {
	ADD,
	SUBTRACT,
	MULTIPLY,
	DIVIDE,
	POW,
}

@export var _animations: Array[StringAnimatorAnimation]
@export var _target_property: StringName
@export var _target: Node

@export var _aggregate_type: Aggre:
	set(to):
		_aggregate_type = to
		_aggregate = _AGGREGATES[int(to)]
var _aggregate: Aggregate
var _floats: Array


func _ready() -> void:
	_aggregate_type = _aggregate_type
	for an in _animations:
		an.init()
		_floats.append(0)


func _physics_process(_delta: float) -> void:
	var t := Engine.get_physics_frames()
	for i in _animations.size():
		_floats[i] = _animations[i].get_value(t)
	var result: float = _floats.reduce(_aggregate.function, _aggregate.minimum)
	_target.set_indexed(NodePath(_target_property), result)


class Aggregate:
	var function: Callable
	var minimum: float

	func _init(fun: Callable, minim: float) -> void:
		function = fun
		minimum = minim