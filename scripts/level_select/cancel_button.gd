extends LinkButton

@onready var animation_player = $"../AnimationPlayer"
@export var sfx : AudioStream

func _on_pressed() -> void:
	animation_player.play("up")
	SoundManager.play_sfx(sfx)
