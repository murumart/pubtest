class_name PlayerActionComponent extends Button

enum {STATE_WAIT, STATE_MENUOPEN}
const AR = ActorComponent.ActionResult

@export var player_char_selection: MGPlayerCharSelection

var state: int = STATE_WAIT


func _ready() -> void:
	assert(is_instance_valid(player_char_selection))
	disabled = true


func act() -> AR:
	disabled = false
	pressed.connect(func():
		player_char_selection.character = get_parent()
		player_char_selection.global_position = global_position + Vector2.RIGHT * 16
		player_char_selection.show()
	, CONNECT_ONE_SHOT)

	var decision: AR = await player_char_selection.decision_made
	if not is_instance_valid(decision) or decision.type == AR.TYPE_NONE:
		disabled = true
		return AR.new().timed(2)

	disabled = true
	return decision
