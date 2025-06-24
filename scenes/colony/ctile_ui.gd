extends Control

signal time_pass_request(amt: int)

const ColonyTile = preload("res://scenes/colony/colony_tile.gd")
const TileTypes = ColonyTile.TileTypes
const dat = preload("res://scenes/colony/data.gd")
const dk = dat.Keys
const res = preload("res://scenes/colony/resources.gd")
const Jobs = preload("res://scenes/colony/jobs.gd")

@export var cursor: Node2D
@export var tile_info_label: Label
@export var resource_info_label: Label
@export var time_info_label: Label
@export var active_jobs_list: ItemList


func _ready() -> void:
	%BackButton.pressed.connect(func():
		owner._save()
		LTS.change_scene_to("res://scenes/colony/world_map.tscn")
	)
	%TimeButton.pressed.connect(func():
		time_pass_request.emit(1 * 60)
	)


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


func update_active_jobs(jobs: Array[Jobs.Job]) -> void:
	active_jobs_list.clear()
	for job in jobs:
		# ignore finished jos
		if job not in Jobs.jobs or not is_instance_valid(job):
			continue
		var title := "job"
		if job.map_tile != Vector2i.ONE * -1:
			title += " at " + str(job.map_tile)
		var ix := active_jobs_list.add_item(title)
		active_jobs_list.set_item_metadata(ix, job)
