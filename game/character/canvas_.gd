extends CanvasLayer

@onready var label = $RichTextLabel

var dialogue = [
	"Another day……\nunchanged, unending.",
	"The sun… \ntoo bright to bear",
	"A street, \nblurred into a wavering haze,",
	"A train, \nalive with the endless cry of cicadas,",
	"A day, \nsteeped in heat shimmer—red as blood.",
	"\n",
	"Time feels as if it has stopped.",
	"……",
	"…………。",
	"It’s so hot, \nunbearably hot..",
	"sunset seeps into my veins\nas though my body might melt away from within."
]

var current_line = 0
var typing_speed = 0.08
var is_typing = false
var skip_typing = false


func _ready():
	play_next_line()


# =========================
# ▶ 播放下一句
# =========================
func play_next_line():
	if current_line >= dialogue.size():
		await ending_sequence()   # ✅ 播放完执行结尾
		return
	
	var text = dialogue[current_line]
	current_line += 1
	
	await type_text(text)
	
	var wait_time = get_pause_time(text)
	await get_tree().create_timer(wait_time).timeout
	
	play_next_line()


# =========================
# ⌨ 打字机
# =========================
func type_text(text):
	label.text = text
	label.visible_characters = 0
	
	is_typing = true
	skip_typing = false
	
	for i in text.length():
		
		if skip_typing:
			label.visible_characters = text.length()
			break
		
		label.visible_characters = i + 1
		
		var c = text[i]
		
		if c in [".", ","]:
			await get_tree().create_timer(0.2).timeout
		elif c in ["…"]:
			await get_tree().create_timer(0.3).timeout
		elif c in ["—"]:
			await get_tree().create_timer(0.25).timeout
		elif c in ["。"]:
			await get_tree().create_timer(0.3).timeout
		else:
			await get_tree().create_timer(typing_speed).timeout
	
	is_typing = false


# =========================
# ⏱ 停顿
# =========================
func get_pause_time(text):
	var clean = text.strip_edges()
	
	if clean in ["……", "…………。"]:
		return 2.5
	
	if text.length() > 40:
		return 1.5
	
	if "……" in text or "..." in text:
		return 2.0
	
	if text.ends_with(".") or text.ends_with("。"):
		return 1.2
	
	if text.length() < 20:
		return 1.0
	
	return 1.2


# =========================
# 🎬 结尾（切场景）
# =========================
func ending_sequence():
	await get_tree().create_timer(2.5).timeout  # 👉 最后停顿
	
	# 👉 切换到 door 场景（改路径！）
	get_tree().change_scene_to_file("res://door.tscn")


# =========================
# 🎮 输入
# =========================
func _input(event):
	if event.is_action_pressed("ui_accept"):
		
		if is_typing:
			skip_typing = true
		else:
			play_next_line()
