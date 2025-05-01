extends Camera2D

const UI := preload("res://scenes/colony/ui.gd")

@export var ui: UI

var speed := 180.0


func _physics_process(delta: float) -> void:
	if ui.console.has_focus():
		return
	var vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	position += vec * speed * delta
