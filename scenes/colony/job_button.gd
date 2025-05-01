extends Button

const Colony := preload("res://scenes/colony/colony.gd")
const Job := preload("res://scenes/colony/job.gd")
const Worker := preload("res://scenes/colony/worker.gd")
const JobButton := preload("res://scenes/colony/job_button.gd")
const _Scene := preload("res://scenes/colony/job_button.tscn")

@onready var menu_container: PanelContainer = $Menu
@onready var worker_container: PanelContainer = $Workers
@onready var itleft: ItemList = $Workers/HBoxContainer/VBoxContainer
@onready var itright: ItemList = $Workers/HBoxContainer/VBoxContainer2


var complete_job: Callable
var job: Job
var colony: Colony


func _ready() -> void:
	menu_container.hide()
	worker_container.hide()
	$Workers/HBoxContainer/VBoxContainer3/Right.pressed.connect(_on_worker_right_clicked)
	$Workers/HBoxContainer/VBoxContainer3/Left.pressed.connect(_on_worker_left_clicked)
	var do := $Menu/Do
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
	)


func _on_option_clicked(option: int) -> void:
	match option:
		0:
			worker_container.visible = not worker_container.visible
			if worker_container.visible: _do_mmmmmmm_uhhhh()
		1:
			var err: Error = complete_job.call()
			if err == OK: queue_free()
		2:
			job.request_removal()
			queue_free()


func _on_worker_right_clicked() -> void:
	var ix := itleft.get_selected_items()
	if ix.is_empty(): return
	var worker := (itleft.get_item_metadata(ix[0]) as Worker)
	job.add_assigned_worker(worker)
	_do_mmmmmmm_uhhhh()


func _on_worker_left_clicked() -> void:
	var ix := itright.get_selected_items()
	if ix.is_empty(): return
	var worker := (itright.get_item_metadata(ix[0]) as Worker)
	job.remove_assigned_worker(worker)
	_do_mmmmmmm_uhhhh()


func _do_mmmmmmm_uhhhh() -> void:
	itleft.clear()
	itright.clear()
	var leftw := colony.workers.keys().filter(func(w: Worker) -> bool: return not job.has_assigned_worker(w))
	var rightw := job.m_get_assigned_workers()
	for w: Worker in leftw:
		var ix := itleft.add_item(w.m_get_name())
		itleft.set_item_metadata(ix, w)
	for w: Worker in rightw:
		var ix := itright.add_item(w.m_get_name())
		itright.set_item_metadata(ix, w)
