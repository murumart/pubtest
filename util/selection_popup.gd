class_name SelectionPopup extends Window

static var _ACCEPT := func() -> void: return

@onready var items: ItemList = %ItemList
@onready var ok_button: Button = %OkButton
@onready var cancel_button: Button = %CancelButton


static func create() -> SelectionPopup:
	var s := preload("res://util/selection_popup.tscn").instantiate()
	return s


func _ready() -> void:
	reset()


func pop(params: Parameters) -> Variant:
	assert(not visible, "dont pop me up now.....")
	assert(params._result_callable.is_valid(), "nununuunun i need a calalble!!!")

	var p := params
	title = p._title if p._title else ""

	_populate_list(p)

	transient = true
	exclusive = true
	show()

	var result: Variant = await params._result_callable.call()
	hide()
	queue_free()
	return result


func _populate_list(p: Parameters) -> void:
	assert(p._input_labels.size() == p._input_labels.size())
	for i in p._input_labels.size():
		var label := p._input_labels[i]
		var object: Variant = p._input_objects[i]

		items.add_item(label, null, true)
		items.set_item_metadata(i, object)
	if p._select_multiple:
		items.select_mode = ItemList.SELECT_MULTI
		items.add_item("okay")
		items.set_item_metadata(p._input_labels.size(), _ACCEPT)


func wait_item_result() -> Variant:
	while true:
		var clicked: Array = await items.item_clicked
		var index: int = clicked[0]
		var mouse: int = clicked[2]

		if mouse != MOUSE_BUTTON_LEFT: continue

		return items.get_item_metadata(index)
	assert(false, "reached end of await_result?")
	return null


func wait_items_result() -> Array:
	assert(false, "you idiiot. this doesnt work")
	while true:
		var clicked: Array = await items.item_clicked
		var index: int = clicked[0]
		var mouse: int = clicked[2]

		if mouse != MOUSE_BUTTON_LEFT: continue
		if index != items.item_count - 1: continue # last one is accept button

		var selected_indices := Array(items.get_selected_items())
		var selected := selected_indices.map(func(i: int) -> Variant: return items.get_item_metadata(i))
		print("indices is: ", selected_indices)
		print("selevted is: ", selected)

		return selected
	assert(false, "reached end of await_result?")
	return []


func reset() -> void:
	hide()
	title = ""
	items.clear()


class Parameters:

	var _input_labels: PackedStringArray
	var _input_objects: Array
	var _title: String
	var _size := Vector2(120, 100)
	var _result_callable: Callable = func() -> void: pass
	var _select_multiple: bool


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


	func set_select_multiple(selmul: bool) -> Parameters:
		_select_multiple = selmul
		return self
