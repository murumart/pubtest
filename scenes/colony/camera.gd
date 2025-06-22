extends Camera2D


func _physics_process(delta: float) -> void:
	var vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	global_position += vec * delta * 120.0


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = Vector2(zoom.x + 0.1, zoom.y + 0.1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = Vector2(zoom.x - 0.1, zoom.y - 0.1)
