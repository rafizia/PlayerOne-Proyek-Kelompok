extends TextureButton

@onready var tutorial_screen = $"../.."

func _on_pressed() -> void:
	get_tree().paused = false
	tutorial_screen.visible = false
