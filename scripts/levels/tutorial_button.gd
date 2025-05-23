extends TextureButton

@onready var tutorial_screen = $"../../TutorialPage"

func _on_pressed() -> void:
	tutorial_screen.visible = true
	get_tree().paused = true
