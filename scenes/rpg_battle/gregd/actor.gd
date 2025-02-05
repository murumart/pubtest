class_name GregDActor extends Node2D

signal act_finished(actor: GregDActor)

var max_health: float
var health: float

var max_magic: float
var magic: float


func act_turn() -> void:
	await get_tree().create_timer(1.0).timeout
	act_finished.emit(self)
