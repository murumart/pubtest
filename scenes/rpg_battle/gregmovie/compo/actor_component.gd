class_name ActorComponent extends Node


func act() -> ActionResult:
	return ActionResult.new().timed(2)


class ActionResult:

	enum {TYPE_NONE, TYPE_MOVE}

	var type: int

	var time := 0.0
	var target_pos: Vector2


	func move_to(target_pos_: Vector2) -> ActionResult:
		type = TYPE_MOVE
		self.target_pos = target_pos_
		return self


	func timed(time_: float) -> ActionResult:
		self.time = time_
		return self
