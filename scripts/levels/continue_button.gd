extends LinkButton

@export var level_path: String

func _on_pressed() -> void:	
	TransitionLayer.transition(true)
	await TransitionLayer.on_transition_finished
	get_tree().change_scene_to_file(level_path)
