extends CharacterBody2D

@export var speed = 90
@export var run_speed = 180

# 🎯 阴影参数（可以在 Inspector 里调！）
@export var shadow_offset = Vector2(0, 12)
@export var shadow_scale_idle = Vector2(0.35, 0.2)
@export var shadow_scale_run = Vector2(0.5, 0.1)
@export var shadow_follow_speed = 0.2

@onready var anim = $AnimatedSprite2D
@onready var shadow = $Shadow

var last_direction = Vector2.DOWN


func _physics_process(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var is_running = Input.is_action_pressed("run")

	# 🟢 移动
	if is_running:
		velocity = direction * run_speed
	else:
		velocity = direction * speed

	move_and_slide()

	# 🟢 动画
	if direction != Vector2.ZERO:
		last_direction = direction
		
		if is_running:
			play_directional_animation(direction, "run")
		else:
			play_directional_animation(direction, "walk")
	else:
		play_directional_animation(last_direction, "idle")

	# 🟢 阴影更新
	update_shadow(delta)


# 🎬 方向动画系统
func play_directional_animation(dir, type):
	var angle = dir.angle()
	var index = int(round(angle / (PI / 4)))
	index = wrapi(index, 0, 8)

	var directions = [
		"right",
		"down_right",
		"down",
		"down_right",
		"right",
		"up_right",
		"up",
		"up_right"
	]

	var base_anim = directions[index]
	var anim_name = type + "_" + base_anim

	var flip = index in [3, 4, 5]
	anim.flip_h = flip

	if anim.animation != anim_name:
		anim.play(anim_name)


func update_shadow(_delta):
	var frame = anim.frame
	var anim_name = anim.animation

	var base_scale = shadow_scale_idle
	var target_scale = base_scale

	# 🟢 不同动画不同节奏
	if anim_name.begins_with("walk") or anim_name.begins_with("run"):
		
		# 👉 根据帧做变化（关键）
		match frame % 4:
			0:
				target_scale = base_scale * Vector2(1.0, 1.0)
			1:
				target_scale = base_scale * Vector2(1.1, 0.9)
			2:
				target_scale = base_scale * Vector2(0.95, 1.05)
			3:
				target_scale = base_scale * Vector2(1.05, 0.95)

	else:
		# 🫁 待机轻微呼吸（可选）
		var t = Time.get_ticks_msec() * 0.003
		var breathe = sin(t) * 0.03
		target_scale = base_scale + Vector2(breathe, breathe * 0.5)

	# 🟢 应用缩放（不要太平滑！否则会糊）
	shadow.scale = shadow.scale.lerp(target_scale, 0.3)

	# 🟢 位置（保持脚下）
	var target_pos = shadow_offset

	if velocity != Vector2.ZERO:
		var dir = velocity.normalized()
		target_pos.x += dir.x * 2
		target_pos.y += dir.y * 1.5

	shadow.position = shadow.position.lerp(target_pos, 0.2)
