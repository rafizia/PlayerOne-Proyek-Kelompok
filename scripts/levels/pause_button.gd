extends TextureButton

@onready var pause_screen = $"../../PauseScreen"

func _on_pressed() -> void:	
	SoundManager.play_click()
	pause_screen.visible = true
	get_tree().paused = true
	AudioServer.get_bus_effect(2,0).volume_db = -10
	
