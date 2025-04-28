const Worker := preload("res://scenes/colony/worker.gd")

var _name: String

# virtual overrides

# construction

static func create_worker(name: String) -> Worker:
	var worker := Worker.new()
	worker._name = name
	
	return worker


# methods
