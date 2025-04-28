const Job = preload("res://scenes/colony/job.gd")

var _jobname: String
#var _time_to_complete := -1.0
var _resources_to_complete: Dictionary[StringName, int]
var _rewards: Dictionary[StringName, int]
var _reward_callback: Callable


# virtual impls

func _to_string() -> String:
	var txt := "job %s" % [_jobname]
	if not _resources_to_complete.is_empty():
		txt += "\nneeded:\n"
	for k in _resources_to_complete:
		var v := _resources_to_complete[k]
		txt += k + ": " + str(v)
	return txt


# constructing

static func create(nomen: String) -> Job:
	var job := Job.new()
	job._jobname = nomen
	
	return job


func time_to_complete(time: int) -> Job:
	#_time_to_complete = time
	add_requirement("time", time)
	return self


func add_requirement(res: StringName, amt: int) -> Job:
	_resources_to_complete[res] = amt
	return self


func add_reward(res: StringName, amt: int) -> Job:
	_rewards[res] = amt
	return self


func set_reward_callback(cb: Callable) -> Job:
	_reward_callback = cb
	return self

# methods


func can_complete(resources: Dictionary[StringName, int]) -> bool:
	for k in _resources_to_complete:
		var v := _resources_to_complete[k]
		if not resources.has(k): return false
		if resources[k] < v: return false
	return true


func deplete(resources: Dictionary[StringName, int]) -> void:
	for k in _resources_to_complete:
		var v := _resources_to_complete[k]
		resources[k] -= v


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
