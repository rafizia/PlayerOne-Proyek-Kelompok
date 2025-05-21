extends LinkButton


func _on_pressed() -> void:
	SoundManager.play_click()
	get_tree().paused = false
	# Reset tower placer manager before transitioning
	var tower_placer = get_node("/root/TowerPlacerManager")
	if tower_placer:
		tower_placer.current_tower = null
		tower_placer.is_dragging = false
		tower_placer.can_place = false
		tower_placer.tilemap_layers = []
	
	TransitionLayer.transition(true)
	await TransitionLayer.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	AudioServer.get_bus_effect(2,0).volume_db = 0
