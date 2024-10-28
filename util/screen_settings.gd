@tool
@icon("res://scenes/rpg_battle/gregmovie/art/spr_greg_overworld.png")
class_name ScreenSettings extends Node2D

@export var window_size := Vector2(1920, 1080)
@export var window_mode_override: Window.Mode
@export var viewport_size := Vector2i(160, 120):
	set(to):
		viewport_size = to
		queue_redraw()
@export var content_scale_mode: Window.ContentScaleMode
@export var content_stretch: Window.ContentScaleStretch


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	draw_rect(Rect2(Vector2.ZERO - global_position, Vector2(viewport_size)),
			Color.WEB_PURPLE, false)


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	var win := get_window()
	win.content_scale_size = viewport_size
	win.size = window_size
	win.mode = window_mode_override
	win.content_scale_mode = content_scale_mode
	win.content_scale_stretch = content_stretch
