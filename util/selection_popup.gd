class_name SelectionPopup extends Window

@onready var items: ItemList = %ItemList


func _ready() -> void:
	reset()


func pop(params: Parameters) -> Variant:
	assert(not visible, "dont pop me up now.....")
	
	var p := params
	title = p._title if p._title else ""
	
	_populate_list(p)
	
	transient = true
	exclusive = true
	show()
	
	var result: Variant = await params._result_callable.call()
	hide()
	reset()
	return result


func _populate_list(p: Parameters) -> void:
	assert(p._input_labels.size() == p._input_labels.size())
	for i in p._input_labels.size():
		var label := p._input_labels[i]
		var object: Variant = p._input_objects[i]
		
		items.add_item(label, null, true)
		items.set_item_metadata(i, object)


func wait_item_result() -> Variant:
	while true:
		var clicked: Array = await items.item_clicked
		var index: int = clicked[0]
		var mouse: int = clicked[2]
		
		if mouse != MOUSE_BUTTON_LEFT: continue
		
		return items.get_item_metadata(index)
	assert(false, "reached end of await_result?")
	return null


func reset() -> void:
	hide()
	title = ""
	items.clear()


class Parameters:
	
	var _input_labels: PackedStringArray
	var _input_objects: Array
	var _title: String
	var _size := Vector2(120, 100)
	var _result_callable: Callable
	
	
	func set_inputs(labels: Array, objects: Array) -> Parameters:
		assert(labels.size() == objects.size(), "inconsistent label and object lists")
		_input_labels = PackedStringArray(labels)
		_input_objects = objects
		return self
	
	
	func set_inputs_d(dict: Dictionary) -> Parameters:
		return set_inputs(dict.keys(), dict.values())
	
	
	func set_inputs_dt(dict: Dictionary[String, Variant]) -> Parameters:
		return set_inputs(dict.keys(), dict.values())


	func set_title(ttle: String) -> Parameters:
		_title = ttle
		return self
	
	
	func set_size(sze: Vector2) -> Parameters:
		_size = sze
		return self
	
	
	func set_result_callable(callable: Callable) -> Parameters:
		_result_callable = callable
		return self
