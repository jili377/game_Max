extends CharacterBody2D

@export var speed: float = 80.0
@export var catch_strength: float = 2.0   # 越大越“吸”
@export var min_distance: float = 8.0     # ⭐ 防抖关键
@export var target_offset: Vector2 = Vector2(0, 10)  # ⭐ 追脚

@onready var anim: AnimatedSprite2D = $"Monster_1"

var player: Node2D = null


func _ready():
	if anim:
		anim.play("monster1")

	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")


func _physics_process(_delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	# ⭐ 追“脚的位置”，不是中心
	var target_pos = player.global_position + target_offset

	var direction = target_pos - global_position
	var distance = direction.length()

	if distance > 0:
		direction = direction.normalized()

	# ⭐ 防止贴脸抖动
	if distance > min_distance:
		var follow_speed = speed + distance * catch_strength
		velocity = direction * follow_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# 👉 左右翻转
	if direction.x < 0:
		anim.flip_h = true
	elif direction.x > 0:
		anim.flip_h = false
