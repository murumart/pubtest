extends "res://scenes/colony/battle/actor.gd"

const Workers = preload("res://scenes/colony/workers.gd")

var worker: Workers.Worker:
	set(to):
		worker = to
		if to == null:
			return
		hp = worker.hp
		max_hp = worker.attributes.get("max hp", 10.0)
		energy = worker.energy
		max_energy = worker.attributes.get("max energy", 10.0)
		name = worker.name
