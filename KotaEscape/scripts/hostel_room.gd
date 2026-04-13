extends Node2D


func _ready() -> void:
	var morning := GameManager.consume_morning_reset()
	if morning:
		GameManager.start_morning()
		match GameManager.day:
			2:
				GameUI.show_toast("Didn't this already happen?", 2.4)
			3:
				GameUI.show_toast("Okay. Test the world.", 2.0)
			_:
				pass
	else:
		if GameManager.pending_toast != "":
			GameUI.show_toast(GameManager.pending_toast)
			GameManager.pending_toast = ""

	$Player.global_position = $SpawnPoint.global_position
	$Bed.interacted.connect(_on_bed)
	$Door.interacted.connect(_on_door)


func _on_bed() -> void:
	if GameManager.phone_open:
		return
	GameUI.show_dialogue(
		"Bed",
		"Same hostel. Same ceiling fan.\nSleep and reset?",
		[
			{"id": "yes", "text": "Sleep (end day)"},
			{"id": "no", "text": "Not yet"},
		],
		Callable(self, "_bed_choice")
	)


func _bed_choice(id: String) -> void:
	if id == "yes":
		GameManager.end_day()


func _on_door() -> void:
	if GameManager.phone_open:
		return
	GameManager.enter_classroom()
	get_tree().change_scene_to_file("res://scenes/classroom.tscn")
