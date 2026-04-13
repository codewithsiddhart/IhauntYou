extends CanvasLayer
## Autoload UI: stats, dialogue choices, phone (TAB).

@onready var stats_label: Label = $Root/StatsPanel/StatsLabel
@onready var prompt_label: Label = $Root/PromptLabel
@onready var dialogue_panel: PanelContainer = $Root/DialoguePanel
@onready var dialogue_title: Label = $Root/DialoguePanel/Margin/VBox/Title
@onready var dialogue_body: Label = $Root/DialoguePanel/Margin/VBox/Body
@onready var choices_box: VBoxContainer = $Root/DialoguePanel/Margin/VBox/Choices
@onready var phone_panel: PanelContainer = $Root/PhonePanel
@onready var phone_messages: RichTextLabel = $Root/PhonePanel/Margin/VBox/Messages
@onready var scroll_button: Button = $Root/PhonePanel/Margin/VBox/ScrollButton
@onready var toast_label: Label = $Root/ToastLabel

var _choice_callback: Callable = Callable()


func is_dialogue_open() -> bool:
	return dialogue_panel.visible


func _ready() -> void:
	layer = 20
	GameManager.stats_changed.connect(_refresh_stats)
	GameManager.day_changed.connect(_on_day_changed)
	GameManager.morning_started.connect(_on_morning)
	GameManager.phone_open_changed.connect(_on_phone_open_changed)
	_refresh_stats()
	dialogue_panel.visible = false
	phone_panel.visible = false
	toast_label.visible = false
	prompt_label.text = ""
	scroll_button.pressed.connect(_on_scroll_pressed)
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_phone"):
		toggle_phone()
		get_viewport().set_input_as_handled()


func toggle_phone() -> void:
	if dialogue_panel.visible:
		return
	GameManager.set_phone_open(not GameManager.phone_open)


func _on_phone_open_changed(is_open: bool) -> void:
	phone_panel.visible = is_open
	if is_open:
		_refresh_phone_messages()


func _on_scroll_pressed() -> void:
	GameManager.phone_scroll_reels()
	_refresh_phone_messages()


func _refresh_stats() -> void:
	stats_label.text = "Day %d  |  Focus: %d  |  Stress: %d" % [
		GameManager.day, GameManager.focus, GameManager.stress
	]


func _on_day_changed(_d: int) -> void:
	_refresh_stats()


func _on_morning(_d: int) -> void:
	_refresh_stats()
	if GameManager.pending_toast != "":
		show_toast(GameManager.pending_toast)
		GameManager.pending_toast = ""


func show_toast(text: String, seconds: float = 3.5) -> void:
	toast_label.text = text
	toast_label.visible = true
	var tw := create_tween()
	tw.tween_interval(seconds)
	tw.tween_callback(func(): toast_label.visible = false)


func set_interact_prompt(text: String) -> void:
	prompt_label.text = text


func clear_interact_prompt() -> void:
	prompt_label.text = ""


## choices: Array of { "id": String, "text": String }
func show_dialogue(title: String, body: String, choices: Array, on_choice: Callable) -> void:
	_choice_callback = on_choice
	dialogue_title.text = title
	dialogue_body.text = body
	for c in choices_box.get_children():
		c.queue_free()
	for ch in choices:
		var b := Button.new()
		b.text = str(ch.get("text", "?"))
		var id: String = str(ch.get("id", ""))
		b.pressed.connect(func(): _pick_choice(id))
		choices_box.add_child(b)
	dialogue_panel.visible = true


func _pick_choice(id: String) -> void:
	dialogue_panel.visible = false
	var cb := _choice_callback
	_choice_callback = Callable()
	if cb.is_valid():
		cb.call(id)


func close_dialogue() -> void:
	dialogue_panel.visible = false
	_choice_callback = Callable()


func _refresh_phone_messages() -> void:
	var d := GameManager.day
	var lines: PackedStringArray = []
	lines.append("[b]Messages[/b]\n")

	lines.append("Mom: Khana khaya?")
	if d >= 2:
		lines.append("Mom: Bas kal se serious ho jaunga — bolna mat. (…wait.)")
	else:
		lines.append("Mom: Bas aaj se serious ho jaunga — bolna mat.")

	lines.append("\nFriend: Test? Main to gaya. Tu?")

	if d >= 2:
		lines.append("\nUnknown: If you read this twice, it's not a bug.")
		lines.append("Unknown: It's Tuesday. (Probably.)")

	if d >= 3:
		lines.append("\nUnknown: Try one different step.")

	if GameManager.left_early_day3:
		lines.append("\n>>> You did something different today.")

	phone_messages.text = "\n".join(lines)


func open_teacher_flow() -> void:
	var d := GameManager.day
	var title := "Sir"
	var body := ""

	if d == 1:
		body = "Open your notes.\nThis question came last year too.\nIf you're tired, sit straight anyway."
	elif d == 2:
		body = "Open your notes.\nThis question came last year too.\nIf you're tired, sit straight anyway.\n\nDid I already say that? …Doesn't matter."
	else:
		body = "Open your notes.\nLast year too.\nSit straight.\n\n…Short class today. Maybe."

	var choices: Array = [
		{"id": "pay", "text": "Pay attention"},
		{"id": "zone", "text": "Zone out"},
		{"id": "half", "text": "Half-listen"},
	]
	if d >= 3:
		choices.append({"id": "leave", "text": "Leave early"})

	show_dialogue(title, body, choices, _on_teacher_choice)


func _on_teacher_choice(id: String) -> void:
	match id:
		"pay":
			GameManager.class_pay_attention()
		"zone":
			GameManager.class_disengage()
		"half":
			GameManager.class_half_listen()
		"leave":
			GameManager.mark_left_early()
			get_tree().change_scene_to_file("res://scenes/hostel_room.tscn")
			return
	_refresh_stats()
