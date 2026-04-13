extends Node2D

func _ready():
	# 播放背景动画（如果有）
	if $AnimatedSprite2D:
		$AnimatedSprite2D.play("idle")


# ===== 按钮功能 =====

func _on_new_game_pressed():
	print("New Game 点击")
	get_tree().change_scene_to_file("res://train.tscn")


func _on_load_game_pressed():
	print("Load Game 点击")
	get_tree().change_scene_to_file("res://SaveMenu.tscn")


func _on_quit_pressed():
	print("Quit 点击")
	get_tree().quit()
