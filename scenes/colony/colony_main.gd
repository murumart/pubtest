extends Control

const WMap = preload("res://scenes/colony/world/world_map.gd")
const Resources = preload("res://scenes/colony/resources.gd")
const Workers = preload("res://scenes/colony/workers.gd")

static var log_label: RichTextLabel


func _ready() -> void:
	%Play.pressed.connect(func() -> void:
		LTS.change_scene_to("res://scenes/colony/world/world_map.tscn", {first = true})
	)
	const Enemy = preload("res://scenes/colony/battle/enemy.gd")
	%Battle.pressed.connect(func() -> void:
		Workers.workers
		LTS.change_scene_to("res://scenes/colony/battle/battle.tscn", {})
	)
	var logger := $Man
	log_label = $Man/LoggerScroll/LogLabel
	remove_child(logger)
	SOL.add_ui_child(logger, 0, false)

	#loge("welcome to colony game")


static func loge(msg: String) -> void:
	msg = str(Resources.day) + " " + Resources.get_time_str() + ": " + msg
	if is_instance_valid(log_label):
		log_label.text = msg + "\n" + log_label.text
	print("LOGGED: ", msg)
