extends "res://scenes/colony/battle/actor.gd"

const Battle = preload("res://scenes/colony/battle/battle.gd")

var context: Battle


func act() -> void:
	if hp <= 0:
		return
	print("enemy " + name + " actingd...")
	var tgts := context.get_targets(context.party)
	if not tgts.is_empty():
		strike(tgts[0])
	await create_tween().tween_interval(1.0).finished


func _on_die() -> void:
	if "scale" in self:
		self.scale.y = 0.5
