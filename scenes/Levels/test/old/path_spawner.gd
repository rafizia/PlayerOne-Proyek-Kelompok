extends Node2D

@onready var path = preload("res://scenes/Levels/test/path_2d_flyer_test.tscn")

func _on_timer_timeout() -> void:
	var tempPath = path.instantiate()
	add_child(tempPath)
	print("time")
