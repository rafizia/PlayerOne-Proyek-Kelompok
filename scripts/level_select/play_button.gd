extends LinkButton

var selected_level_path: String = ""


func _on_pressed() -> void:
	SoundManager.play_click()
	TransitionLayer.transition(true)
	await TransitionLayer.on_transition_finished
	get_tree().change_scene_to_file(selected_level_path)
