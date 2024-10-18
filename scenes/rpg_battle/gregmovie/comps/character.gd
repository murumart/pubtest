class_name MGCharacter extends CharacterBody2D

signal selection_requested(mgchar: MGCharacter)

@export_group("Components")
@export var component_mouse_select: MGCharacterMouseSelect


func _ready() -> void:
	_signal_setup()


func _signal_setup() -> void:
	if is_instance_valid(component_mouse_select):
		component_mouse_select.pressed.connect(request_select)


func request_select() -> void:
	selection_requested.emit(self)
