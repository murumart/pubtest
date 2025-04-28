class_name SelectionPopup extends Window

@onready var items: ItemList = %ItemList


func _ready() -> void:
	reset()


func pop(params: Parameters) -> Variant:
	assert(not visible, "dont pop me up now.....")
	
	var p := params
	title = p.title if p.title else ""
	
	_populate_list(p)
	
	transient = true
	exclusive = true
	show()
	
	var result: Variant = await _await_result()
	hide()
	reset()
	return result


func _populate_list(p: Parameters) -> void:
	assert(p.input_labels.size() == p.input_labels.size())
	for i in p.input_labels.size():
		var label := p.input_labels[i]
		var object: Variant = p.input_objects[i]
		
		items.add_item(label, null, true)
		items.set_item_metadata(i, object)


func _await_result() -> Variant:
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
	
	var input_labels: PackedStringArray
	var input_objects: Array
	var title: String
	var size := Vector2(120, 100)
	
	
	func set_inputs(labels: Array, objects: Array) -> Parameters:
		assert(labels.size() == objects.size(), "inconsistent label and object lists")
		input_labels = PackedStringArray(labels)
		input_objects = objects
		return self
	
	
	func set_inputs_d(dict: Dictionary) -> Parameters:
		return set_inputs(dict.keys(), dict.values())
	
	
	func set_inputs_dt(dict: Dictionary[String, Variant]) -> Parameters:
		return set_inputs(dict.keys(), dict.values())


	func set_title(ttle: String) -> Parameters:
		title = ttle
		return self
	
	
	func set_size(sze: Vector2) -> Parameters:
		size = sze
		return self
