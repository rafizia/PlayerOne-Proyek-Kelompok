extends LinkButton

@onready var arrow_label = $"../PlayArrowLabel"

func _on_mouse_entered() -> void:
	arrow_label.text = "▶"

func _on_mouse_exited() -> void:
	arrow_label.text = ""
	
func _on_pressed() -> void:
	TransitionLayer.transition(false)
	await TransitionLayer.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
