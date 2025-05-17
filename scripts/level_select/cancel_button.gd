extends LinkButton

@onready var animation_player = $"../AnimationPlayer"

func _on_pressed() -> void:
	animation_player.play("up")
