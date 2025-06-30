extends Node

const Actor = preload("res://scenes/colony/battle/actor.gd")
const ColonyMain = preload("res://scenes/colony/colony_main.gd")

@export var max_hp: float
@export var hp: float:
	set(to):
		hp = to
		if to <= 0:
			ColonyMain.loge(name + " died!!")
			_on_die()
@export var max_energy: int
@export var energy: int


func _ready() -> void:
	pass


func get_attack() -> float:
	return 1.0


func strike(whom: Actor) -> void:
	ColonyMain.loge(name + " struck " + whom.name)
	var dmg := get_attack()
	whom.hp -= dmg
	ColonyMain.loge(whom.name + " lost " + str(dmg) + " hp")
	energy = maxi(0, energy - 3)


func _on_die() -> void:
	pass
