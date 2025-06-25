extends CanvasLayer

# screen layer over everything else. used for things like UI

signal fade_finished

@export var show_fps := false
var fps_label: Label

@onready var screen_fade_order := $ScreenFadeOrderer


func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	if show_fps:
		fps_label = Label.new()
		add_ui_child(fps_label, 120, false)


func _input(_event: InputEvent) -> void:
	if show_fps and is_instance_valid(fps_label):
		fps_label.text = str(Engine.get_frames_per_second())


# when a node needs to be at the top of the world
func add_ui_child(node: Node, custom_z_index := 0, delete_on_scene_change := true) -> void:
	var node2d := Node2D.new()
	add_child(node2d)
	node2d.z_index = custom_z_index
	# remove them on scene change since they are no longer attached to their
	# original scenes
	if delete_on_scene_change:
		node2d.add_to_group("free_on_scene_change")
	node2d.add_child(node)


func move_ui_child(child: Node, position: int) -> void:
	move_child(child.get_parent(), position)


func fade_screen(start: Color, end: Color, time := 1.0, options := {}) -> void:
	if options.get("kill_rects", false):
		for child: Node in screen_fade_order.get_children():
			child.queue_free()
	var tw := create_tween()
	var rect := ColorRect.new()
	rect.size = get_window().get_size_with_decorations()
	rect.color = start
	screen_fade_order.add_child(rect)
	tw.tween_property(rect, "color", end, time)
	tw.tween_callback(func():
		self.fade_finished.emit()
		if is_instance_valid(rect) and options.get("free_rect", true):
			rect.queue_free()
	)


# simpler access to shake the camera
func shake(amt: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if not is_instance_valid(cam): return
	if cam.has_method("add_trauma"):
		cam.add_trauma(amt)


func display_dict_editor(dict: Dictionary, options := {}) -> DebugDictEditor:
	var editor := load("res://util/scn_dict_editor.tscn").instantiate() as DebugDictEditor
	add_ui_child(editor, 0, false)
	editor.handle_options(options)
	editor.load_dict(dict)
	return editor


func vfx_damage_number(pos: Vector2, text: String, color := Color.WHITE, size := 1.0, options := {}) -> void:
	var o := {"text": text, "size": size, "color": color}
	o.merge(options)
	vfx("damage_number", pos, o)


# spawn vfx effects
func vfx(nomen: StringName, pos := Vector2(), options := {}) -> Node:
	# the nomen must be the filenam
	var effect: Node2D = load("res://scenes/vfx/scn_vfx_%s.tscn" % nomen).instantiate()
	effect.z_index = options.get("z_index", 100)
	# can specify custom parent node to the effect, defaults to this here SOL
	var parent: Node = options.get("parent", self)
	parent.add_child(effect)
	effect.add_to_group("vfx")
	# option to silence
	if options.get("silent", false):
		for i in get_all_children_of_type(effect, "AudioStreamPlayer"):
			i = i as AudioStreamPlayer
			i.volume_db = -80
			i.bus = "Master"
		for i in get_all_children_of_type(effect, "AudioStreamPlayer2D"):
			i.queue_free()
			i = i as AudioStreamPlayer2D
			i.volume_db = -80
			i.bus = "Master"
	# some effects have scripts, this is where they are called
	if effect.has_method(&"init"):
		effect.init(options)
	# this solution was found after much testing.
	# not perfect...
	if not "global_position" in parent:
		effect.global_position = pos + get_window().get_size_with_decorations() / 2.0
	else:
		effect.global_position = pos

	#effect.global_position = pos
	if options.get("random_rotation", false):
		effect.rotation = randf_range(-TAU, TAU)
	effect.scale = options.get("scale", Vector2(1, 1))
	# most effects have queue_free() calls built into their animations
	if options.get("free_time", -1.0) > 0:
		get_tree().create_timer(options.get("free_time")).timeout.connect(
			func():
				effect.queue_free()
		, CONNECT_ONE_SHOT)
	return effect


func clear_vfx() -> void:
	for i in get_tree().get_nodes_in_group("vfx"):
		i.queue_free()


func get_all_children_of_type(node: Node, type: String) -> Array:
	var nods := []
	for c in node.get_children():
		if c.get_class() == type:
			nods.append(c)
		if c.get_child_count() > 0:
			nods.append_array(get_all_children_of_type(c, type))
	return nods


var _ldisplay_label_y := 0.0
func make_display_label(object: Object, thing: StringName) -> Label:
	var label := Label.new()
	var np := NodePath(thing)
	add_ui_child(label)
	label.process_frame.connect(func():
		label.text = str(object.get_indexed(np))
	)
	label.position.y = _ldisplay_label_y
	_ldisplay_label_y += label.size.y + 4.0
	return label
