extends Control

const VISIBLE_DICE = 8

const DIE = preload("res://scenes/rpg_battle/gregd/dice/die.tscn")
const Die = preload("res://scenes/rpg_battle/gregd/dice/die.gd")

@export var film_reel: HBoxContainer

@onready var player_actor_display: PanelContainer = $ClickableStuff/PlayerActorDisplay
@onready var action_options: PanelContainer = %ActionOptions
@onready var selection_menu: PanelContainer = %SelectionMenu
@onready var selection_list: ItemList = %SelectionList
@onready var info_display: RichTextLabel = %InfoDisplay


func _ready() -> void:
	populate_dice()


func _input(event: InputEvent) -> void:
	pass


func populate_dice() -> void:
	for i in VISIBLE_DICE:
		add_die()


func add_die() -> Die:
	var die: Die = DIE.instantiate()
	die.number = randi_range(1, 6)
	film_reel.add_child(die)
	return die


func pop_die() -> int:
	var childs: Array[Die]
	childs.assign(film_reel.get_children())
	var die: Die = childs.pop_front()
	film_reel.remove_child(die)
	add_die()
	return die.number
