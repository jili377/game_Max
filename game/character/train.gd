extends Node2D

@onready var sound = $TrainSound

var base_volume = -10

func _ready():
	sound.play()

func _process(_delta):
	var t = Time.get_ticks_msec() * 0.001
	
	# 🔊 音量波动
	var volume_wave = sin(t * 1.5) * 2.0
	var volume_noise = randf_range(-0.5, 0.5)
	sound.volume_db = base_volume + volume_wave + volume_noise
	
	# 🎧 左右偏移（用 position）
	var pan_wave = sin(t * 0.7) * 0.2
	var pan_noise = randf_range(-0.05, 0.05)
	
	var pan_value = clamp(pan_wave + pan_noise, -1.0, 1.0)
	sound.position.x = pan_value * 200
