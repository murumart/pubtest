extends Control

const WMap = preload("res://scenes/colony/world_map.gd")


func _play_pressed() -> void:
	LTS.change_scene_to("res://scenes/colony/world_map.tscn", {first = true})
