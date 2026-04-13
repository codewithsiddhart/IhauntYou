extends Control


func _ready() -> void:
	$Center/VBox/Hint.text = "You can change this."


func _on_quit_pressed() -> void:
	get_tree().quit()
