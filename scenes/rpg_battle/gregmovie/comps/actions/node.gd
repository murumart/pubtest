extends Node2D


func set_polygons(polygons: Array[PackedVector2Array]) -> void:
	for i: int in polygons.size():
		if i: get_child(0).duplicate()
		get_child(i).get_child(0).polygon = polygons[i]
		get_child(i).get_child(1).get_child(0).polygon = polygons[i]
