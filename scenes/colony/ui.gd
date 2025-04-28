extends Control

const Place := preload("res://scenes/colony/place.gd")
const Worker := preload("res://scenes/colony/worker.gd")

signal job_completion_requested

@export var _mouse_label: Label
@export var _resources_label: Label
@export var _workers_label: Label
@export var _job_completion_button: Button
@export var popup: SelectionPopup


func _ready() -> void:
	_job_completion_button.pressed.connect(job_completion_requested.emit)


func display_place(pos: Vector2i, place: Place) -> void:
	_mouse_label.text = "%d, %d" % [pos.x, pos.y]
	if not is_instance_valid(place):
		_mouse_label.text += " (empty)"
		return
	_mouse_label.text += " (%s)" % place.name


func display_resources(resources: Dictionary[StringName, int]) -> void:
	var txt := "resources:\n"
	for k in resources:
		var v := resources[k]
		txt += k + ": " + str(v)
		txt += "\n"
	_resources_label.text = txt


func display_workers(workers: Dictionary[Worker, bool]) -> void:
	var txt := "workers:\n"
	for w in workers:
		txt += w._name + "\n"
	_workers_label.text = txt
