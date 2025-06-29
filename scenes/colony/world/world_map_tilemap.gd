extends TileMapLayer

const ColonyTile = preload("res://scenes/colony/world/colony_tile.gd")
const Civs = preload("res://scenes/colony/civs.gd")

signal tile_clicked(pos: Vector2i, tiletype: Vector2i, claimed: bool)

enum SaveKey {
	CLAIMED_TILES,
	TILES,
}

const TileTypes: Dictionary[StringName, Vector2i] = {
	LAND = Vector2i(0, 0),
	SEA = Vector2i(1, 0)
}

const SIZE := 20

@export var _noise: FastNoiseLite
static var noise: FastNoiseLite
@export var target_display: Node2D
@export var info: Label
@export var drawer: CanvasItem


func _ready() -> void:
	scale = Vector2(ColonyTile.SIZE, ColonyTile.SIZE)
	noise = _noise
	if drawer:
		drawer.draw.connect(func() -> void:
			for tile in get_used_cells():
				if tile not in Civs.civs[0].claimed_tiles:
					drawer.draw_rect(Rect2(
						tile.x * 16,
						tile.y * 16,
						16,
						16
					), Color(0, 0, 0, 0.5))
		)


func generate() -> void:
	noise.seed = randi()
	for y in SIZE:
		for x in SIZE:

			var sum := noise.get_noise_2d(
				x * ColonyTile.SIZE + ColonyTile.SIZE * 0.5,
				y * ColonyTile.SIZE + ColonyTile.SIZE * 0.5)

			set_cell(Vector2i(x, y), 0, TileTypes.LAND)
			if sum / (ColonyTile.SIZE**2) < 0:
				set_cell(Vector2i(x, y), 0, TileTypes.SEA)
	for y in range(SIZE / 2 - 1, SIZE / 2 + 1):
		for x in range(SIZE / 2 - 1, SIZE / 2 + 1):
			Civs.civs[0].lay_claim(Vector2i(x, y))


func savef() -> Dictionary:
	const sk := SaveKey
	var d := {}
	d[sk.TILES] = {}
	for tpos in get_used_cells():
		var cell := get_cell_atlas_coords(tpos)
		d[sk.TILES][tpos] = cell
	return d


func loadf(d: Dictionary) -> void:
	const sk := SaveKey
	for k: Vector2i in d[sk.TILES]:
		set_cell(k, 0, d[sk.TILES][k])


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var epos: Vector2 = get_canvas_transform().affine_inverse() * event.global_position
		var tpos := local_to_map(to_local(epos))

		if target_display:
			target_display.global_position = tpos * tile_set.tile_size * scale.x

		if info:
			info.text = "Tile at " + str(tpos)
			info.text += "\nType: " + str(TileTypes.find_key(get_cell_atlas_coords(tpos)))
			info.text += "\nClaimed: " + str(tpos in Civs.civs[0].claimed_tiles)

	if event is InputEventMouseButton:
		var epos: Vector2 = get_canvas_transform().affine_inverse() * event.global_position
		var tpos := local_to_map(to_local(epos))
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			tile_clicked.emit(tpos, get_cell_atlas_coords(tpos), tpos in Civs.civs[0].claimed_tiles)

	if drawer:
			drawer.queue_redraw()
