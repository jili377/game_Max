extends Area2D

@export var item_name: String = "Item"

func pickup():
	print("Picked up: ", item_name)
	queue_free() # 删除物体（表示被捡了）
