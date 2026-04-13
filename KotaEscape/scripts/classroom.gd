extends Node2D


func _ready() -> void:
	$Player.global_position = $SpawnPoint.global_position
	$Teacher.interacted.connect(_on_teacher)
	$Door.interacted.connect(_on_door)


func _on_teacher() -> void:
	if GameManager.phone_open:
		return
	GameUI.open_teacher_flow()


func _on_door() -> void:
	if GameManager.phone_open:
		return
	get_tree().change_scene_to_file("res://scenes/hostel_room.tscn")
