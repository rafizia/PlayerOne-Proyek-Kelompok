extends LinkButton

@onready var arrow_label = $"../SettingsArrowLabel"
@onready var sound_setting = $"../SoundSetting"

func _on_mouse_entered() -> void:
	arrow_label.text = "▶"
	SoundManager.play_click()

func _on_mouse_exited() -> void:
	arrow_label.text = ""
	
func _on_pressed() -> void:	
	SoundManager.play_click()
	sound_setting.visible = true
	
