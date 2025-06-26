const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys

static var civs: Array[Civ]


static func _static_init() -> void:
	dat.sets(dk.CIVS, civs)

	if true:
		var civ := Civ.new()
		civ.name = "your capital"
		civ.standing[0] = 10
		civs.append(civ)
	if true:
		var civ := Civ.new()
		civ.name = "nature"
		civs.append(civ)


class Civ:
	var name: String
	var standing: Dictionary[int, int]
	var claimed_tiles: Array[Vector2i]


	func change_standing(with: int, by: int) -> void:
		if not with in standing:
			standing[with] = 0
		standing[with] += by


	func lay_claim(tile: Vector2i) -> void:
		claimed_tiles.append(tile)


	func info() -> String:
		return "Civ " + name
