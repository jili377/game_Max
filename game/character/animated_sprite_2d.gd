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
var current_item: Area2D = null

# ===== UI 图标 =====
@onready var pickup_icon: Sprite2D = $PickupIcon
var icon_base_pos := Vector2.ZERO
var icon_base_scale := Vector2.ONE
var icon_time := 0.0
var icon_tween: Tween

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var pickup_area: Area2D = $PickupArea

# ===== 🔦 手电筒 =====
@onready var flashlight: Sprite2D = $Flashlight
var flashlight_on := true
var flashlight_base_scale := Vector2.ONE

var last_direction = Vector2.DOWN


func _ready():
	add_to_group("player")   # ⭐ 关键：让怪物能找到你
	
	current_speed = speed
	
	pickup_icon.visible = false
	
	icon_base_pos = pickup_icon.position
	icon_base_scale = pickup_icon.scale
	
	flashlight.visible = flashlight_on
	flashlight_base_scale = flashlight.scale
	
	pickup_area.area_entered.connect(_on_pickup_area_area_entered)
	pickup_area.area_exited.connect(_on_pickup_area_area_exited)


func _physics_process(delta):

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var want_run = Input.is_action_pressed("run")

	# ===== 移动 =====
	is_running = want_run and stamina > 0.0 and direction != Vector2.ZERO
	target_speed = run_speed if is_running else speed

	var stamina_ratio = stamina / max_stamina
	target_speed *= pow(stamina_ratio, 1.3) + 0.3

	current_speed = lerp(current_speed, target_speed, 5.0 * delta)
	velocity = direction * current_speed
	move_and_slide()

	# ===== 跑步判断 =====
	var run_blend = clamp(current_speed / run_speed, 0.0, 1.0)

	if is_actually_running:
		if run_blend < 0.55:
			is_actually_running = false
	else:
		if run_blend > 0.75:
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


func _process(delta):
	if pickup_icon.visible:
		icon_time += delta
		
		var float_y = sin(icon_time * 2.5) * 2.5
		var jitter_x = sin(icon_time * 3.7) * 1.2
		var jitter_y = cos(icon_time * 4.3) * 1.0
		
		var rot = sin(icon_time * 3.0) * 0.05
		var s = 1.0 + sin(icon_time * 5.0) * 0.03
		
		pickup_icon.position = icon_base_pos + Vector2(jitter_x, float_y + jitter_y)
		pickup_icon.rotation = rot
		pickup_icon.scale = icon_base_scale * s

	update_flashlight(delta)
	toggle_flashlight()


# ===== 🔦 手电筒 =====

func update_flashlight(_delta):
	if !flashlight_on:
		return

	flashlight.rotation = last_direction.angle()

	var t = Time.get_ticks_msec() / 1000.0
	var flicker = 1.0 + sin(t * 8.0) * 0.02

	flashlight.scale = flashlight_base_scale * flicker


func toggle_flashlight():
	if Input.is_action_just_pressed("flashlight_toggle"):
		flashlight_on = !flashlight_on
		flashlight.visible = flashlight_on


# ===== 拾取检测 =====

func _on_pickup_area_area_entered(area: Area2D) -> void:
	current_item = area
	pickup_icon.visible = true
	icon_time = 0.0


func _on_pickup_area_area_exited(area: Area2D) -> void:
	if area == current_item:
		current_item = null
		pickup_icon.visible = false


# ===== 动画系统 =====

func play_directional_animation(dir: Vector2, type: String):

	var angle = dir.angle()
	var index = int(round(angle / (PI / 4)))
	index = wrapi(index, 0, 8)

	var directions = [
		"right","down_right","down","down_left",
		"left","up_left","up","up_right"
	]

	var base_anim = directions[index]

	var use_anim = base_anim
	if base_anim == "left":
		use_anim = "right"
	elif base_anim == "down_left":
		use_anim = "down_right"
	elif base_anim == "up_left":
		use_anim = "up_right"

	var anim_name = type + "_" + use_anim

	anim.flip_h = base_anim in ["left", "down_left", "up_left"]

	if anim.animation != anim_name:
		anim.play(anim_name)
