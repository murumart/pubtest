extends TextureRect

const TEXTURE_DIE_1 = preload("res://scenes/rpg_battle/gregd/dice/die1.png")
const TEXTURE_DIE_2 = preload("res://scenes/rpg_battle/gregd/dice/die2.png")
const TEXTURE_DIE_3 = preload("res://scenes/rpg_battle/gregd/dice/die3.png")
const TEXTURE_DIE_4 = preload("res://scenes/rpg_battle/gregd/dice/die4.png")
const TEXTURE_DIE_5 = preload("res://scenes/rpg_battle/gregd/dice/die5.png")
const TEXTURE_DIE_6 = preload("res://scenes/rpg_battle/gregd/dice/die6.png")

const TEXTURES := [
	TEXTURE_DIE_1,
	TEXTURE_DIE_2,
	TEXTURE_DIE_3,
	TEXTURE_DIE_4,
	TEXTURE_DIE_5,
	TEXTURE_DIE_6,
]

@export_range(1, 6) var number := 1:
	set(to):
		number = to
		texture = TEXTURES[to - 1]


func _ready() -> void:
	number = number


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("ohhh click the die my numer is ", number)
