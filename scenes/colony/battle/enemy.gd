extends "res://scenes/colony/battle/actor.gd"

const Battle = preload("res://scenes/colony/battle/battle.gd")

var context: Battle


func act() -> void:
	print("enemy " + name + " actingd...")
	var tgts := context.get_targets(context.party)
	if not tgts.is_empty():
		strike(tgts[0])
	await create_tween().tween_interval(1.0).finished
