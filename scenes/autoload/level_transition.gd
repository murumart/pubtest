extends Node

# handles changing scenes

signal scene_changed


# instead of get_tree().change_scene() or whatever
func change_scene_to(path: String, options := {}) -> void:
	var last_scene := get_current_scene()

	last_scene.queue_free()
	var free_us := get_tree().get_nodes_in_group("free_on_scene_change")
	if options.get("free_those_nodes", true):
		for node in free_us:
			node.call_deferred("queue_free")

	await get_tree().process_frame

	var new_scene: Node = load(path).instantiate()
	get_tree().root.add_child.call_deferred(new_scene, false)

	if new_scene.has_method("_option_init"):
		await new_scene.ready
		new_scene._option_init(options)

	scene_changed.emit()


# this should be a default gdscript function cmon
# turns out it kinda is already. damn
func get_current_scene() -> Node:
	#return get_tree().current_scene
	return get_tree().root.get_child(-1)


func enter_battle(_info, _options := {}) -> void:
	pass
