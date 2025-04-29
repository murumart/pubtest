extends Button

const Job := preload("res://scenes/colony/job.gd")
const JobButton := preload("res://scenes/colony/job_button.gd")
const _Scene := preload("res://scenes/colony/job_button.tscn")

var complete_job: Callable


static func instantiate() -> JobButton:
	return _Scene.instantiate()


func init(job: Job, on_complete := func() -> void: pass) -> void:
	text = job._jobname
	complete_job = on_complete
	
	pressed.connect(func() -> void:
		var err: Error = complete_job.call()
		if err == OK: queue_free()
	)
