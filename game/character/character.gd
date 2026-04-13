extends Node2D

@onready var phone_ui = $CanvasLayer/phone_ui

var is_phone_open = false





func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_phone()


func toggle_phone():
	is_phone_open = !is_phone_open
	phone_ui.visible = is_phone_open

	get_tree().paused = is_phone_open
