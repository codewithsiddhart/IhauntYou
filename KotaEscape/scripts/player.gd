extends CharacterBody2D

const SPEED := 200.0

@onready var interaction_zone: Area2D = $InteractionZone


func _physics_process(delta: float) -> void:
	if GameManager.phone_open:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if dir.length_squared() > 1.0:
		dir = dir.normalized()
	velocity = dir * SPEED
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if GameManager.phone_open or GameUI.is_dialogue_open():
		return
	if event.is_action_pressed("interact"):
		_try_interact()


func _try_interact() -> void:
	for a in interaction_zone.get_overlapping_areas():
		if a.has_method("request_interact"):
			a.request_interact()
			get_viewport().set_input_as_handled()
			return
