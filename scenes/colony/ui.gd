extends Control

@export var mouse_label: Label


func display_tile(data: TileData, pos: Vector2i) -> void:
	mouse_label.text = "%d, %d" % [pos.x, pos.y]
	if not is_instance_valid(data):
		mouse_label.text += " (empty)"
		return
	mouse_label.text += " (%d)" % data.get_custom_data("tileid")
