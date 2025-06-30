extends Node

const Actor = preload("res://scenes/colony/battle/actor.gd")
const ColonyMain = preload("res://scenes/colony/colony_main.gd")

var max_hp: float
var hp: float:
	set(to):
		hp = to
		if to <= 0:
			ColonyMain.loge(name + " died!!")
var max_energy: int
var energy: int


func _ready() -> void:
	hp = 10


func act() -> void:
	assert(false, "pls implement me in supclass.............................")


func get_attack() -> float:
	return 1.0


func strike(whom: Actor) -> void:
	ColonyMain.loge(name + " struck " + whom.name)
	var dmg := get_attack()
	whom.hp -= dmg
	ColonyMain.loge(whom.name + " lost " + str(dmg) + " hp")
