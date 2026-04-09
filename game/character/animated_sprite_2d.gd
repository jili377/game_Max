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

var is_actually_running := false

# ===== 拾取 =====
var current_item = null

@onready var anim = $AnimatedSprite2D
@onready var shadow = $Shadow
@onready var pickup_area = $PickupArea

var last_direction = Vector2.DOWN


func _ready():
	current_speed = speed

	# 连接拾取检测
	pickup_area.area_entered.connect(_on_area_entered)
	pickup_area.area_exited.connect(_on_area_exited)


func _physics_process(delta):

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var want_run = Input.is_action_pressed("run")

	# ===== 移动逻辑 =====
	is_running = want_run and stamina > 0.0 and direction != Vector2.ZERO

	target_speed = run_speed if is_running else speed

	var stamina_ratio = stamina / max_stamina
	target_speed *= pow(stamina_ratio, 1.3) + 0.3

	current_speed = lerp(current_speed, target_speed, 5.0 * delta)

	velocity = direction * current_speed
	move_and_slide()

	# ===== 跑步状态 =====
	var run_blend = clamp(current_speed / run_speed, 0.0, 1.0)

	var enter_threshold = 0.75
	var exit_threshold = 0.55

	if is_actually_running:
		if run_blend < exit_threshold:
			is_actually_running = false
	else:
		if run_blend > enter_threshold:
			is_actually_running = true

	# ===== 耐力 =====
	if is_actually_running:
		stamina -= drain_rate * delta
	else:
		stamina += recover_rate * delta

	stamina = clamp(stamina, 0.0, max_stamina)

	# ===== 动画 =====
	if direction != Vector2.ZERO:
		last_direction = direction

		if is_actually_running:
			play_directional_animation(direction, "run")
		else:
			play_directional_animation(direction, "walk")

		var speed_ratio = clamp(current_speed / run_speed, 0.0, 1.0)
		anim.speed_scale = lerp(0.6, 2.0, speed_ratio)
	else:
		play_directional_animation(last_direction, "idle")
		anim.speed_scale = 1.0

	# ===== 拾取 =====
	if Input.is_action_just_pressed("interact") and current_item:
		current_item.pickup()


# ===== 检测 =====
func _on_area_entered(area):
	current_item = area


func _on_area_exited(area):
	if area == current_item:
		current_item = null


# ===== 动画系统 =====
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
