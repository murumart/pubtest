extends Control

const WMap = preload("res://scenes/colony/world_map.gd")

static var log_label: RichTextLabel


func _ready() -> void:
	var logger := $Man
	log_label = $Man/LoggerScroll/LogLabel
	remove_child(logger)
	SOL.add_ui_child(logger, 0, false)

	loge("welcome to colony game")


func _play_pressed() -> void:
	LTS.change_scene_to("res://scenes/colony/world_map.tscn", {first = true})


static func loge(msg: String) -> void:
	log_label.text = msg + "\n" + log_label.text
	print("LOGGED: ", msg)
