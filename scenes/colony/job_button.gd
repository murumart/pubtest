extends Button

const Colony := preload("res://scenes/colony/colony.gd")
const Job := preload("res://scenes/colony/job.gd")
const Worker := preload("res://scenes/colony/worker.gd")
const JobButton := preload("res://scenes/colony/job_button.gd")
const _Scene := preload("res://scenes/colony/job_button.tscn")

@onready var menu_container: PanelContainer = $Menu
var complete_job: Callable

var job: Job
var colony: Colony


func _ready() -> void:
	menu_container.hide()
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
			pass
		1:
			var err: Error = complete_job.call()
			if err == OK: queue_free()
		2:
			job.request_removal()
			queue_free()
