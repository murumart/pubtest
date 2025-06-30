extends Control

const PartyMember = preload("res://scenes/colony/battle/party_member.gd")
const Enemy = preload("res://scenes/colony/battle/enemy.gd")
const Actor = preload("res://scenes/colony/battle/actor.gd")
const ColonyMain = preload("res://scenes/colony/colony_main.gd")

signal action_chosen(callalbe: Callable)

@onready var enemies: Node = %Enemies
@onready var party: Node = %Party
@onready var actor_actions: Panel = %ActorActions

var turn := 0
var stats: Dictionary[StringName, int]


func _ready() -> void:
	%StrikeButton.pressed.connect(func() -> void:
		var sp: SelectionPopup
		var tgts := get_targets(enemies)
		var tgt: Variant
		while tgt is not Actor:
			sp = SelectionPopup.create()
			add_child(sp)
			tgt = await sp.pop(sp.Parameters.new()
			.set_title("attack whom..")
			.set_inputs(tgts.map(func(a: Node)-> String: return a.name), tgts)
			.set_result_callable(sp.wait_item_result)
			.set_ok_cancel(false, true)
		)
		action_chosen.emit(func(initiator: Actor) -> void:
			initiator.strike(tgt)
		)
	)
	while true:
		await party_turn()
		if get_targets(enemies).is_empty():
			ColonyMain.loge("party won!!!")
			break
		await enemy_turn()
		if get_targets(party).is_empty():
			ColonyMain.loge("enemy won!!!")
			await get_tree().create_timer(1.0).timeout
			LTS.change_scene_to("res://scenes/colony/game_over.tscn")
			break


func party_turn() -> void:
	print("player turn..")
	for p: PartyMember in party.get_children():
		actor_actions.show()
		%MemberInfo.update(p)
		var fun : Callable = await action_chosen
		actor_actions.hide()
		fun.call(p)
	print("tunr over")
	await get_tree().create_timer(1.0).timeout


func enemy_turn() -> void:
	print("enemt turn...")
	for p: Enemy in enemies.get_children():
		p.context = self
		await p.act()
	print("turn over")
	await get_tree().create_timer(1.0).timeout


func get_targets(which_group: Node) -> Array:
	return which_group.get_children().filter(func(a: Node) -> bool:
		return a is Actor and a.hp >= 0
	)
