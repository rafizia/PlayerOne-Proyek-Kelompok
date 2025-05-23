extends LinkButton

@onready var play_button = $"../../Confirm_Dialog/Play"
@onready var animation_player = $"../../Confirm_Dialog/AnimationPlayer"
@export var level_path: String
@export var sfx: AudioStream


func _on_pressed() -> void:	
	animation_player.play("drop")
	play_button.selected_level_path = level_path
	SoundManager.play_sfx(sfx)


func _on_mouse_entered() -> void:
	SoundManager.play_click()
