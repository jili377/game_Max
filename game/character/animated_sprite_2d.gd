extends CharacterBody2D

@export var speed: float = 90.0
@export var run_speed: float = 180.0

# ===== 耐力 =====
var max_stamina: float = 100.0
var stamina: float = 100.0

var drain_rate: float = 12.5
var recover_rate: float = 18

var is_running := false

# ===== 平滑速度 =====
var current_speed: float = 0.0
var target_speed: float = 0.0

# 🎯 真实跑步状态（迟滞）
var is_actually_running := false

@onready var anim = $AnimatedSprite2D
@onready var shadow = $Shadow   # 不控制

var last_direction = Vector2.DOWN


func _ready():
	current_speed = speed


func _physics_process(delta):

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var want_run = Input.is_action_pressed("run")

	# =========================
	# 💥 输入 → 目标速度
	# =========================
	is_running = want_run and stamina > 0.0 and direction != Vector2.ZERO

	if is_running:
		target_speed = run_speed
	else:
		target_speed = speed

	# 💥 体力影响速度
	var stamina_ratio = stamina / max_stamina
	target_speed *= pow(stamina_ratio, 1.3) + 0.3

	# =========================
	# 💥 平滑速度
	# =========================
	current_speed = lerp(current_speed, target_speed, 5.0 * delta)

	# =========================
	# 🟢 移动
	# =========================
	velocity = direction * current_speed
	move_and_slide()

	# =========================
	# 🎯 run_blend
	# =========================
	var run_blend = current_speed / run_speed
	run_blend = clamp(run_blend, 0.0, 1.0)

	# =========================
	# 🔥 迟滞（防抖动）
	# =========================
	var enter_threshold = 0.75
	var exit_threshold = 0.55

	if is_actually_running:
		if run_blend < exit_threshold:
			is_actually_running = false
	else:
		if run_blend > enter_threshold:
			is_actually_running = true

	# =========================
	# 💥 耐力变化
	# =========================
	if is_actually_running:
		stamina -= drain_rate * delta
	else:
		stamina += recover_rate * delta

	stamina = clamp(stamina, 0.0, max_stamina)

	# =========================
	# 🟢 动画
	# =========================
	if direction != Vector2.ZERO:
		last_direction = direction

		if is_actually_running:
			play_directional_animation(direction, "run")
		else:
			play_directional_animation(direction, "walk")

		# 🎯 动画速度 = 跟随真实移动速度（🔥关键）
		var speed_ratio = current_speed / run_speed
		speed_ratio = clamp(speed_ratio, 0.0, 1.0)

		# 最低0.6（拖步） → 最高2.0（冲刺）
		anim.speed_scale = lerp(0.6, 2.0, speed_ratio)

	else:
		play_directional_animation(last_direction, "idle")
		anim.speed_scale = 1.0


# 🎬 动画系统
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
