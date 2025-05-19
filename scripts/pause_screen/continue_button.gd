extends LinkButton

@onready var pause_screen = $"../.."


func _on_pressed() -> void:
	pause_screen.visible = false
	get_tree().paused = false
	
