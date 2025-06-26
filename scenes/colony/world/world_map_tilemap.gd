extends TileMapLayer

const ColonyTile = preload("res://scenes/colony/world/colony_tile.gd")

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

var claimed_tiles: Array[Vector2i]


func _ready() -> void:
	noise = _noise
	if drawer:
		drawer.draw.connect(func() -> void:
			for tile in get_used_cells():
				if tile not in claimed_tiles:
					drawer.draw_rect(Rect2(tile.x * 16, tile.y * 16, 16, 16), Color(0, 0, 0, 0.5))
		)


func generate() -> void:
	noise.seed = randi()
	for y in SIZE:
		for x in SIZE:
			var sum := 0.0
			for yy in ColonyTile.SIZE: for xx in ColonyTile.SIZE:
				sum += noise.get_noise_2d(x * SIZE + xx, y * SIZE + yy)

			set_cell(Vector2i(x, y), 0, TileTypes.LAND)
			if sum / (ColonyTile.SIZE**2) < 0:
				set_cell(Vector2i(x, y), 0, TileTypes.SEA)
	for y in range(SIZE / 2 - 1, SIZE / 2 + 1):
		for x in range(SIZE / 2 - 1, SIZE / 2 + 1):
			claimed_tiles.append(Vector2i(x, y))


func savef() -> Dictionary:
	const sk := SaveKey
	var d := {}
	d[sk.CLAIMED_TILES] = claimed_tiles
	d[sk.TILES] = {}
	for tpos in get_used_cells():
		var cell := get_cell_atlas_coords(tpos)
		d[sk.TILES][tpos] = cell
	return d


func loadf(d: Dictionary) -> void:
	const sk := SaveKey
	claimed_tiles = d[sk.CLAIMED_TILES]
	for k: Vector2i in d[sk.TILES]:
		set_cell(k, 0, d[sk.TILES][k])


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var epos: Vector2 = get_canvas_transform().affine_inverse() * event.global_position
		var tpos := local_to_map(to_local(epos))

		if target_display:
			target_display.global_position = tpos * tile_set.tile_size

		if info:
			info.text = "Tile at " + str(tpos)
			info.text += "\nType: " + str(TileTypes.find_key(get_cell_atlas_coords(tpos)))
			info.text += "\nClaimed: " + str(tpos in claimed_tiles)

	if event is InputEventMouseButton:
		var epos: Vector2 = get_canvas_transform().affine_inverse() * event.global_position
		var tpos := local_to_map(to_local(epos))
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			tile_clicked.emit(tpos, get_cell_atlas_coords(tpos), tpos in claimed_tiles)

	if drawer:
			drawer.queue_redraw()
