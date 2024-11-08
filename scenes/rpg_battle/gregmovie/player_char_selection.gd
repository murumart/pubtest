class_name MGPlayerCharSelection extends Control

const AR := ActorComponent.ActionResult

signal decision_made(decision: AR)

@export var mouse_follower: MGGridMouseFollower
@export var grid: MGActorGrid
@export var character: MGCharacter
@onready var tabs: TabContainer = $Tabs


func _ready() -> void:
	$Tabs/Main/MainMenu/InfoButton.pressed.connect(func():
		tabs.current_tab = 2
	)
	$Tabs/Main/MainMenu/ActButton.pressed.connect(func():
		tabs.current_tab = 3
	)
	$Tabs/Main/MainMenu/MoveButton.pressed.connect(func():
		tabs.current_tab = 1
		hide()
		mouse_follower.activate_with(
				grid.global_pos_to_spot(character.global_position), 2)
		mouse_follower.grid_clicked.connect(func(pos: Vector2) -> void:
			mouse_follower.set_active(false)
			decision_made.emit(AR.new().timed(1.0).move_to(pos))
			finish()
		)
	)


func finish() -> void:
	tabs.current_tab = 0


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			tabs.current_tab = 0
