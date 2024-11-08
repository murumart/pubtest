class_name MGGridMouseFollower extends Node2D

signal grid_clicked(gridpos: Vector2)

const COLOR_NORMAL := Color(1, 1, 1, 0.435)
const COLOR_UNSELECTABLE := Color(1, 0.392, 0.51, 0.435)

static var GRID_SIZE_PX := MGActorGrid.GRID_SIZE_PX
static var DOWNSIZE_MULT := 1 / float(GRID_SIZE_PX)

@export var grid: MGActorGrid
@onready var display: ColorRect = $ColorRect

var _active := false
var _centre_position := Vector2()
var _range: int = 0xFFFFFFFFFFFFFFF


func _ready() -> void:
	set_active(false)


func _process(delta: float) -> void:
	var gridpos := grid.global_position
	var pos_in_grid := ((get_global_mouse_position() - gridpos)
			* DOWNSIZE_MULT).floor()

	global_position = gridpos + pos_in_grid * GRID_SIZE_PX

	display.color = COLOR_NORMAL
	var clickable := get_clickable(pos_in_grid)
	if not clickable:
		display.color = COLOR_UNSELECTABLE

	if clickable and Input.is_action_just_pressed("click"):
		grid_clicked.emit(pos_in_grid)


func activate_with(centre_pos := Vector2.ZERO, range := 0xFFFFFFFFFFFFFFF) -> void:
	set_params(centre_pos, range)
	set_active(true)


func set_params(centre_pos: Vector2, range: int) -> void:
	_centre_position = centre_pos
	_range = range


func get_clickable(gridpos: Vector2) -> bool:
	return _active and (
			_centre_position.distance_squared_to(gridpos) < _range * _range
	)


func set_active(to: bool) -> void:
	_active = to
	visible = to
	set_process(to)
