class_name ActorComponent extends Node


func act() -> ActionResult:
	return ActionResult.new().timed(2)


class ActionResult:
	
	var time := 0.0
	
	
	func timed(time: float) -> ActionResult:
		self.time = time
		return self
