class_name MGCharSelection extends Control


var character: MGCharacter


func open(character: MGCharacter) -> void:
	self.character = character
	position = character.position + Vector2(36, -8)
	show()
	character.component_movement.set_process_unhandled_input(false)


func close() -> void:
	hide()
	character.component_movement.set_process_unhandled_input(true)



func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if $Tabs.current_tab == 0:
			close()
		else:
			$Tabs.current_tab = 0
		accept_event()
