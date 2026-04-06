extends AnimatedSprite2D

func _ready():
	play("door_ani")
	$door_Sound.play()
