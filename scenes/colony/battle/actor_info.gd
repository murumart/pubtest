extends Panel

const Actor = preload("res://scenes/colony/battle/actor.gd")

@onready var portrait = $Portrait
@onready var name_label := $Name
@onready var effect_center := $EffectCenter
@onready var health_bar := $HealthBar
@onready var magic_bar := $MagicBar
@onready var wait_bar := $WaitBar
@onready var animal_bar: ProgressBar = $AnimalBar

@onready var effects_container := $EffectsContainer
@onready var remote_transform: RemoteTransform2D = $RemoteTransform


func update(actor: Actor) -> void:

	name_label.text = str(actor.name)
	health_bar.max_value = actor.max_hp
	health_bar.value = actor.hp
	magic_bar.max_value = actor.max_energy
	magic_bar.value = actor.energy
	wait_bar.max_value = 1.0
	animal_bar.visible = false
	#remote_transform.position = Vector2(12, 12)
	if actor.hp <= 0.0:
		portrait.modulate.a = 0.5


#func effects_display(actor: BattleActor) -> void:
	#for i in effects_container.get_children():
		#effects_container.remove_child(i)
		#i.queue_free()
	#for e: BattleStatusEffect in actor.status_effects.values():
		#var type := e.type
		#var rect := TextureRect.new()
		#rect.texture = type.icon
		#rect.flip_v = e.strength < 0
		#effects_container.add_child(rect)
