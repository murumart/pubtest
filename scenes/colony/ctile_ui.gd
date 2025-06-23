extends Control

const ColonyTile = preload("res://scenes/colony/colony_tile.gd")
const TileTypes = ColonyTile.TileTypes
const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const res = preload("res://scenes/colony/resources.gd")

@export var cursor: Node2D
@export var tile_info_label: Label
@export var resource_info_label: Label
@export var time_info_label: Label


func update_cursor(tpos: Vector2i, tile: ColonyTile) -> void:
	cursor.global_position = tpos * tile.tiles.tile_set.tile_size

	tile_info_label.text = "Tile at " + str(tpos)
	tile_info_label.text += "\nType: " + str(TileTypes.find_key(tile.tiles.get_cell_atlas_coords(tpos))).to_lower()
	tile_info_label.text += "\nColony Tile at: " + str(tile.ctile_pos)


func update_resources() -> void:
	var txt := ""
	for k in res.resources.keys():
		txt += str(k) + ": " + str(res.resources[k]) + "\n"
	resource_info_label.text = txt

	time_info_label.text = "Time: " + str(res.time)
