extends Camera2D


func _physics_process(delta: float) -> void:
	var vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var zlvl := 5 / zoom.x
	global_position += vec * delta * 120.0 * zlvl


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var zlvl := zoom.x * 0.1
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = Vector2(zoom.x + zlvl, zoom.y + zlvl)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = Vector2(zoom.x - zlvl, zoom.y - zlvl)
