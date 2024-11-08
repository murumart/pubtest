extends ActorComponent

@export var grid: MGActorGrid

@onready var character: MGCharacter = get_parent()


func act() -> ActionResult:

	var current_position := grid.pos_to_spot(character.position)

	await create_tween().tween_interval(1.0).finished

	return ActionResult.new().move_to(current_position - Vector2i.RIGHT).timed(1.0)
