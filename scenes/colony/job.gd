const Job = preload("res://scenes/colony/job.gd")
const Worker = preload("res://scenes/colony/worker.gd")

signal completed
signal completed_self(job: Job)
signal removal_requested

var _jobname: String
var _time_to_complete := -1.0
var _resource_requirements: Dictionary[StringName, int]
var _rewards: Dictionary[StringName, int]
var _reward_callback: Callable
var _assigned_workers: Array[Worker]


# virtual impls

func _to_string() -> String:
	var txt := "job %s" % [_jobname]
	if not _resource_requirements.is_empty():
		txt += "\nneeded:\n"
	for k in _resource_requirements:
		var v := _resource_requirements[k]
		txt += k + ": " + str(v)
	return txt


# constructing

static func create(nomen: String) -> Job:
	var job := Job.new()
	job._jobname = nomen
	
	return job


func time_to_complete(time: float) -> Job:
	_time_to_complete = time
	return self


func add_requirement(res: StringName, amt: int) -> Job:
	_resource_requirements[res] = amt
	return self


func add_reward(res: StringName, amt: int) -> Job:
	_rewards[res] = amt
	return self


func set_reward_callback(cb: Callable) -> Job:
	_reward_callback = cb
	return self


# methods

func can_complete(resources: Dictionary[StringName, int], timeleft: float) -> bool:
	if m_get_time() > timeleft: return false
	for k in _resource_requirements:
		var v := _resource_requirements[k]
		if not resources.has(k): return false
		if resources[k] < v: return false
	return true


func complete(resources: Dictionary[StringName, int], timeleft: float) -> float:
	assert(can_complete(resources, timeleft), "job incompletable")
	for k in _resource_requirements:
		var v := _resource_requirements[k]
		resources[k] -= v
	completed_self.emit(self)
	completed.emit()
	return timeleft - m_get_time()


func reward(resources: Dictionary[StringName, int]) -> void:
	for k in _rewards:
		var v := _rewards[k]
		if not resources.has(k):
			resources[k] = 0
		resources[k] += v
	_reward_callback.call()


func draw(canvas: CanvasItem, position: Vector2) -> void:
	canvas.draw.connect(func() -> void:
		canvas.draw_multiline_string(
				preload("res://fonts/gregorious.ttf"),
				position,
				to_string())
	, CONNECT_ONE_SHOT)
	canvas.queue_redraw()


func m_get_name() -> String:
	return _jobname


static func get_name(job: Job) -> String:
	return job.m_get_name()


func m_get_time() -> float:
	assert(_time_to_complete >= 0, "time uninitialised?")
	var div = maxf(_assigned_workers.size(), 1)
	return maxf(_time_to_complete / div, 1.0)


static func get_time(job: Job) -> float:
	return job.m_get_time()


func request_removal() -> void:
	removal_requested.emit()


func m_get_assigned_workers_t() -> Array[Worker]:
	var a: Array[Worker] = []
	a.assign(_assigned_workers)
	return _assigned_workers


func m_get_assigned_workers() -> Array:
	var a := []
	a.assign(_assigned_workers)
	return a


func remove_assigned_worker(w: Worker) -> void:
	if w not in _assigned_workers:
		assert(false, "how can you remove if there is not. doumpass")
	_assigned_workers.erase(w)


func has_assigned_worker(w: Worker) -> bool:
	return w in _assigned_workers


func add_assigned_worker(w: Worker) -> void:
	if w in _assigned_workers:
		assert(false, "you shouldnt be doupling them")
	_assigned_workers.append(w)


func get_string_description() -> String:
	var t := m_get_time()
	var txt := "time: "
	txt += str(t)
	for r in _resource_requirements:
		var a := _resource_requirements[r]
		txt += "\n" + r + ": " + str(a)
	txt += "\nresults:"
	for r in _rewards:
		var a := _rewards[r]
		txt += "\n" + r + ": " + str(a)

	return txt