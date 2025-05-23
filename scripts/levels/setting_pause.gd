extends LinkButton

@onready var sound_setting = $"../../SoundSetting"

func _on_pressed() -> void:
	SoundManager.play_click()
	sound_setting.visible = true
	AudioServer.set_bus_effect_enabled(2, 0, false)
	AudioServer.set_bus_effect_enabled(1, 0, false)
	
