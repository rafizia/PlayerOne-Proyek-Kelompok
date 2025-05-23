extends LinkButton

@onready var sound_setting = $"../.."


func _on_pressed() -> void:
	SoundManager.play_click()
	sound_setting.visible = false
	AudioServer.set_bus_effect_enabled(2, 0, true)
	AudioServer.set_bus_effect_enabled(1, 0, true)
	


func _on_mouse_entered() -> void:
	SoundManager.play_click()
