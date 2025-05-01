extends Button

const Colony := preload("res://scenes/colony/colony.gd")
const Job := preload("res://scenes/colony/job.gd")
const Worker := preload("res://scenes/colony/worker.gd")
const JobButton := preload("res://scenes/colony/job_button.gd")
const _Scene := preload("res://scenes/colony/job_button.tscn")

@onready var menu_container: PanelContainer = $Menu
@onready var worker_container: PanelContainer = $Workers
@onready var list_left: ItemList = $Workers/HBoxContainer/VBoxContainer
@onready var list_right: ItemList = $Workers/HBoxContainer/VBoxContainer2
@onready var info_label: Label = $Menu/VBoxContainer/Info

var complete_job: Callable
var job: Job
var colony: Colony


func _ready() -> void:
	menu_container.hide()
	worker_container.hide()
	info_label.hide()
	$Workers/HBoxContainer/VBoxContainer3/Right.pressed.connect(_on_worker_right_clicked)
	$Workers/HBoxContainer/VBoxContainer3/Left.pressed.connect(_on_worker_left_clicked)
	var do := $Menu/VBoxContainer/Do
	for i in do.get_child_count():
		var b: Button = do.get_child(i)
		b.pressed.connect(_on_option_clicked.bind(i))


static func instantiate() -> JobButton:
	return _Scene.instantiate()


func init(p_job: Job, p_colony: Colony, on_complete := func() -> void: pass) -> void:
	job = p_job
	colony = p_colony
	text = p_job._jobname
	complete_job = on_complete

	pressed.connect(func() -> void:
		menu_container.visible = not menu_container.visible
		info_label.visible = not info_label.visible
		if info_label.visible:
			_display_info()
	)


func _on_option_clicked(option: int) -> void:
	match option:
		0:
			worker_container.visible = not worker_container.visible
			if worker_container.visible: _populate_lists()
		1:
			var err: Error = complete_job.call()
			if err == OK: queue_free()
		2:
			job.request_removal()
			queue_free()


func _on_worker_right_clicked() -> void:
	var ix := list_left.get_selected_items()
	if ix.is_empty(): return
	var worker := (list_left.get_item_metadata(ix[0]) as Worker)
	job.add_assigned_worker(worker)
	_populate_lists()


func _on_worker_left_clicked() -> void:
	var ix := list_right.get_selected_items()
	if ix.is_empty(): return
	var worker := (list_right.get_item_metadata(ix[0]) as Worker)
	job.remove_assigned_worker(worker)
	_populate_lists()


func _populate_lists() -> void:
	list_left.clear()
	list_right.clear()
	var leftw := colony.workers.keys().filter(func(w: Worker) -> bool: return not job.has_assigned_worker(w))
	var rightw := job.m_get_assigned_workers()
	for w: Worker in leftw:
		var ix := list_left.add_item(w.m_get_name())
		list_left.set_item_metadata(ix, w)
	for w: Worker in rightw:
		var ix := list_right.add_item(w.m_get_name())
		list_right.set_item_metadata(ix, w)
	_display_info()


func _display_info() -> void:
	info_label.text = job.get_string_description()
