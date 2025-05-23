extends LinkButton

@onready var level_scene = $"../.."
@onready var start_battle_icon = $".."

func _on_pressed() -> void:
	SoundManager.play_click()
	level_scene.start_wave()
	start_battle_icon.visible = false
