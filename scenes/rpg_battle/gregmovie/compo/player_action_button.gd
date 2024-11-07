class_name PlayerActionComponent extends Button

enum {STATE_WAIT, STATE_MENUOPEN}
const AR = ActorComponent.ActionResult

@export var player_char_selection: Control

var state: int = STATE_WAIT


func _ready() -> void:
	assert(is_instance_valid(player_char_selection))
	disabled = true


func act() -> AR:
	disabled = false
	pressed.connect(func():
		player_char_selection.global_position = global_position + Vector2.RIGHT * 16
		player_char_selection.show()
	, CONNECT_ONE_SHOT)
	
	while true:
		match state:
			STATE_WAIT:
				pass
			STATE_MENUOPEN:
				pass
		await get_tree().process_frame
	
	disabled = true
	return AR.new().timed(2)
