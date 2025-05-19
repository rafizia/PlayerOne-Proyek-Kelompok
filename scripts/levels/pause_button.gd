extends TextureButton

@onready var pause_screen = $"../../PauseScreen"


func _on_pressed() -> void:	
	pause_screen.visible = true
	get_tree().paused = true
