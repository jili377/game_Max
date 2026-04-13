extends Control

@onready var anim = $click_load          # AnimatedSprite2D
@onready var btn = $load                 # Button

func _ready():
	# 初始状态
	anim.visible = false
	anim.stop()

	# 连接信号（最稳，不用手动连）
	btn.pressed.connect(_on_load_pressed)
	anim.animation_finished.connect(_on_anim_finished)

func _on_load_pressed():
	print("pressed!")   # 👈 测试用（一定要看到这个）

	anim.visible = true
	anim.play("click_load")   # 👈 你的动画名字

func _on_anim_finished():
	anim.visible = false
