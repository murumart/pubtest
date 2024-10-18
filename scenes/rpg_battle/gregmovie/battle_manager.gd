extends Node

@export var actor_grid: MGActorGrid


func _ready() -> void:
	_signal_setup()


func _signal_setup() -> void:
	for c in actor_grid.get_characters():
		c.selection_requested.connect(_on_char_selection_requested)


func _on_char_selection_requested(mgchar: MGCharacter) -> void:
	select(mgchar)


func select(mgchar: MGCharacter) -> void:
	pass
