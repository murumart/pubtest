extends Control

const Place := preload("res://scenes/colony/place.gd")
const Worker := preload("res://scenes/colony/worker.gd")
const Console := preload("res://scenes/colony/console.gd")
const Job := preload("res://scenes/colony/job.gd")
const Colony := preload("res://scenes/colony/colony.gd")

signal job_completion_requested

@export var _mouse_label: Label
@export var _resources_label: Label
@export var _workers_label: Label
@export var _job_completion_button: Button
@export var popup: SelectionPopup
@export var console: Console

@export var colony: Colony


func _ready() -> void:
	_job_completion_button.pressed.connect(job_completion_requested.emit)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		console.release_focus()


func display_place(pos: Vector2i, place: Place) -> void:
	_mouse_label.text = "%d, %d" % [pos.x, pos.y]
	if not is_instance_valid(place):
		_mouse_label.text += " (empty)"
		return
	_mouse_label.text += " (%s)" % place.name


func display_resources(resources: Dictionary[StringName, int], time: float) -> void:
	var txt := "resources:\n"
	txt += "time: %.2f\n" % time
	for k in resources:
		var v := resources[k]
		txt += k + ": " + str(v)
		txt += "\n"
	_resources_label.text = txt


func display_workers(workers: Dictionary[Worker, bool]) -> void:
	var txt := "workers:\n"
	for w in workers:
		txt += w.m_get_name() + "\n"
	_workers_label.text = txt


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_mousestuff(event)

	display_resources(colony.resources, colony.time)
	display_workers(colony.workers)

	colony.queue_redraw()


func _mousestuff(event: InputEventMouse) -> void:
	var mousepos := colony.get_canvas_transform().affine_inverse() * event.global_position
	var tilepos := colony.tiles.local_to_map(colony.tiles.to_local(mousepos))

	var _err := colony.draw.connect(func() -> void:
		colony.draw_rect(Rect2(tilepos.x * 16, tilepos.y * 16, 16, 16), Color(Color.WHITE, 0.2))
	, CONNECT_ONE_SHOT)

	if not is_instance_valid(colony.grid.get(tilepos)):
		colony.grid.erase(tilepos)
	var place: Place = colony.grid.get(tilepos)
	display_place(tilepos, place)

	var mevent := (event as InputEventMouseButton)
	if mevent != null and mevent.pressed and not SelectionPopup.instance.visible:
		if not is_instance_valid(place):
			return
		_clicked_place(tilepos, place)


func _clicked_place(pos: Vector2i, place: Place) -> void:
	place.clicked_on()
	if place.has_active_job(): return
	var selected: Job = await SelectionPopup.instance.pop(SelectionPopup.Parameters.new()
			.set_inputs(
				place._jobs.keys().map(Job.get_name),
				place._jobs.keys())
			.set_title("select job")
			.set_result_callable(SelectionPopup.instance.wait_item_result))
	colony.place_job(pos, selected)
	#print("selected", selected)
