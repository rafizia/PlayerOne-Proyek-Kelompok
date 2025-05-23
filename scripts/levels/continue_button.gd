extends LinkButton

@export var level_path: String

func _on_pressed() -> void:	
	SoundManager.play_click()
	get_tree().paused = false
	
	ResourcesManager.hp = 20
	ResourcesManager.gold = 50
	ResourcesManager.energy = 100
	
	TransitionLayer.transition(true)
	await TransitionLayer.on_transition_finished
	get_tree().change_scene_to_file(level_path)
