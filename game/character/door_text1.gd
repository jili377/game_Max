extends CanvasLayer

@onready var label = $RichTextLabel

var dialogue = [
	"\n",
	"\n",
	"…………",
	"My face… look pale.",
	"\n",
	"\n",
	"Should go home now.",
]

var current_line = 0
var typing_speed = 0.06

var is_typing = false
var skip_typing = false
var is_waiting = false   # ✅ 防止跳句的关键


# =========================
# ▶ 开始
# =========================
func _ready():
	play_next_line()


# =========================
# ▶ 播放下一句
# =========================
func play_next_line():
	if is_waiting:
		return
	
	if current_line >= dialogue.size():
		await ending_sequence()
		return
	
	is_waiting = true
	
	var text = dialogue[current_line]
	current_line += 1
	
	await type_text(text)
	
	var wait_time = get_pause_time(text)
	await get_tree().create_timer(wait_time).timeout
	
	is_waiting = false
	play_next_line()


# =========================
# ⌨ 打字机效果
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
			# ✅ 短句句号更压抑
			if text.length() <= 5:
				await get_tree().create_timer(0.6).timeout
			else:
				await get_tree().create_timer(0.3).timeout
		else:
			await get_tree().create_timer(typing_speed).timeout
	
	is_typing = false


# =========================
# ⏱ 停顿逻辑
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
	await get_tree().create_timer(2.5).timeout
	
	#get_tree().change_scene_to_file("res://door.tscn")


# =========================
# 🎮 输入控制
# =========================
func _input(event):
	if event.is_action_pressed("ui_accept"):
		
		if is_typing:
			skip_typing = true
		
		elif not is_waiting:
			play_next_line()
