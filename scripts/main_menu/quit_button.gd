extends LinkButton

@onready var arrow_label = $"../QuitArrowLabel"

func _on_mouse_entered() -> void:
	arrow_label.text = "▶"

func _on_mouse_exited() -> void:
	arrow_label.text = ""
	
func _on_pressed() -> void:
	get_tree().quit()
