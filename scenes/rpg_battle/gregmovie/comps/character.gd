class_name MGCharacter extends CharacterBody2D

signal selection_requested(mgchar: MGCharacter)

signal action_requested(who: MGCharacter, action: MGAction)
signal move_requested(action: MGMoveAction)

enum Flags {
	NONE = 0,
	PLAYER_CONTROLLED = 1,
}

var is_acting := false

@export_group("Components")
@export var component_mouse_select: MGCharacterMouseSelect
@export var component_movement: MGMoveComponent
@export_flags("Player Controlled") var _flags: int


func _ready() -> void:
	_signal_setup()


func _signal_setup() -> void:
	if is_instance_valid(component_mouse_select):
		component_mouse_select.pressed.connect(request_select)


func request_action(action: MGAction) -> void:
	assert(not is_acting, "Can't act!!! Already acting!!")
	action_requested.emit(self, action)


func request_select() -> void:
	selection_requested.emit(self)


func request_move(action: MGMoveAction) -> void:
	move_requested.emit(action)


func is_player_controlled() -> bool:
	if _flags & Flags.PLAYER_CONTROLLED:
		return true
	return false


func _to_string() -> String:
	return "Character(flags: " + str(_flags) + ")"
