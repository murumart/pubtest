extends Control

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
	)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			tabs.current_tab = 0
