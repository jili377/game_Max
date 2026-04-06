extends CanvasLayer

@onready var label = $Panel/RichTextLabel

# 🎬 对话内容（你可以换成自己的）
var dialogue = [
	"Another day……",
	"unchanged, unending.",
	"The sun… too bright to bear.",
	"A silent street.",
	"A silent train.",
	"It’s unbearably hot.",
	"The sunset seeps into me."
]

var current_line = 0

# 打字机参数
var typing_speed = 0.03
var is_typing = false


func _ready():
	play_next_line()


# 🎯 播放下一句
func play_next_line():
	if current_line >= dialogue.size():
		return
	
	var text = dialogue[current_line]
	current_line += 1
	
	await type_text(text)
	
	# ⏱ 自动停顿后进入下一句
	await get_tree().create_timer(1.0).timeout
	
	play_next_line()


# 🎬 打字机效果
func type_text(text):
	label.text = text
	label.visible_characters = 0
	
	is_typing = true
	
	for i in text.length():
		label.visible_characters = i + 1
		
		# 👁 标点停顿（更自然）
		if text[i] in [".", "…", ","]:
			await get_tree().create_timer(0.2).timeout
		else:
			await get_tree().create_timer(typing_speed).timeout
	
	is_typing = false


# 🖱 点击跳过
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			# 👉 直接显示整句
			label.visible_characters = label.text.length()
			is_typing = false
