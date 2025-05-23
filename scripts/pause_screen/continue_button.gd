extends LinkButton

@onready var pause_screen = $"../.."


func _on_pressed() -> void:
	SoundManager.play_click()
	pause_screen.visible = false
	get_tree().paused = false
	AudioServer.get_bus_effect(2,0).volume_db = 0
	
