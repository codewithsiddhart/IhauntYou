extends Area2D
## Interactable hotspot. Physics layer 3 ("interactable"). Player InteractionZone masks this layer.

signal interacted

@export var prompt_text: String = "E — Interact"


func _ready() -> void:
	collision_layer = 4
	collision_mask = 2
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameUI.set_interact_prompt(prompt_text)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameUI.clear_interact_prompt()


func request_interact() -> void:
	interacted.emit()
