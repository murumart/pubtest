extends Camera2D

var speed := 180.0


func _physics_process(delta: float) -> void:
	var vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	position += vec * speed * delta
