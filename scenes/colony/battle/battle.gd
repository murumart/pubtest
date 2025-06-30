extends Control

const PartyMember = preload("res://scenes/colony/battle/party_member.gd")
const Enemy = preload("res://scenes/colony/battle/enemy.gd")
const Actor = preload("res://scenes/colony/battle/actor.gd")
const ColonyMain = preload("res://scenes/colony/colony_main.gd")
const Workers = preload("res://scenes/colony/workers.gd")
const Worker = Workers.Worker

signal action_chosen(callalbe: Callable)
signal battle_finished

@onready var enemies: Node = %Enemies
@onready var party: Node = %Party
@onready var actor_actions: Panel = %ActorActions

var turn := 0
var stats: Dictionary[StringName, int]


func _ready() -> void:
	_connect_buttons()
	party.get_children().map(func(a:Node)->void:a.free())
	var suitable_workers := Workers.workers.filter(func(a: Worker) -> bool: return not a.dead)
	print(suitable_workers)
	var howmany_needed := mini(3, suitable_workers.size())
	while party.get_child_count() < howmany_needed:
		var sp := SelectionPopup.create()
		SOL.add_ui_child(sp)
		var s := suitable_workers.filter(func(a: Worker) -> bool:
			return not party.get_children().any(func(b: Node) -> bool:
				return b is PartyMember and b.worker == a
			)
		)
		s.sort_custom(func(a: Worker, b: Worker) -> bool:
			return a.attributes.get(&"combat", 0) > b.attributes.get("combat", 0)
		)
		var w: Workers.Worker = await sp.pop(sp.Parameters.new()
			.set_title("defendants (" + str(howmany_needed  - party.get_child_count()) + " left")
			.set_inputs(s.map(func(a: Workers.Worker) -> String: return a.name), s)
			.set_result_callable(sp.wait_item_result)
		)

		var pm := PartyMember.new()
		pm.worker = w
		party.add_child(pm)

	while true:
		await party_turn()
		if get_targets(enemies).is_empty():
			ColonyMain.loge("party won!!!")
			finish()
			break
		await enemy_turn()
		if get_targets(party).is_empty():
			ColonyMain.loge("enemy won!!!")
			await get_tree().create_timer(1.0).timeout
			LTS.change_scene_to("res://scenes/colony/game_over.tscn")
			break


func _option_init(options: Dictionary) -> void:
	#enemies.get_children().map(func(a:Node)->void:a.free())
	pass


func _connect_buttons() -> void:
	%StrikeButton.pressed.connect(func() -> void:
		var tgts := get_targets(enemies)
		var tgt: Variant
		while tgt is not Actor:
			var sp := SelectionPopup.create()
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


func party_turn() -> void:
	print("player turn..")
	for p: PartyMember in get_targets(party):
		actor_actions.show()
		%MemberInfo.update(p)
		var fun : Callable = await action_chosen
		actor_actions.hide()
		fun.call(p)
	print("tunr over")
	await get_tree().create_timer(1.0).timeout


func enemy_turn() -> void:
	print("enemt turn...")
	for p: Enemy in get_targets(enemies):
		if p.hp <= 0:
			continue
		p.context = self
		await p.act()
	print("turn over")
	await get_tree().create_timer(1.0).timeout


func get_targets(which_group: Node) -> Array:
	return which_group.get_children().filter(func(a: Node) -> bool:
		return a is Actor and a.hp > 0 and a.energy > 0
	)


func finish() -> void:
	for w: PartyMember in get_targets(party):
		w.worker.hp = w.hp
		w.worker.energy = w.energy
		w.worker.gain_xp("combat", 5.0)
	battle_finished.emit()
