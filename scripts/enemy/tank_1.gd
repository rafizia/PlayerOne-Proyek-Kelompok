extends CharacterBody2D  # Atau Node2D

signal enemy_died

@export var speed: float = 100
var path_follow: PathFollow2D

func _process(delta):
	if path_follow:
		path_follow.progress += speed * delta
		global_position = path_follow.global_position

		if path_follow.progress_ratio >= 1.0:
			emit_signal("enemy_died")
			queue_free()
