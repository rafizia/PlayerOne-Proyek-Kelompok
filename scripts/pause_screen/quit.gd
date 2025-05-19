extends LinkButton


func _on_pressed() -> void:
	get_tree().paused = false
	TransitionLayer.transition(true)
	await TransitionLayer.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
