extends LinkButton


func _on_pressed() -> void:
	get_tree().paused = false
	# Reset tower placer manager before transitioning
	var tower_placer = get_node("/root/TowerPlacerManager")
	if tower_placer:
		tower_placer.current_tower = null
		tower_placer.is_dragging = false
		tower_placer.can_place = false
		tower_placer.tilemap_layers = []
		
	ResourcesManager.hp = 20
	ResourcesManager.gold = 50
	ResourcesManager.energy = 100
	
	TransitionLayer.transition(true)
	await TransitionLayer.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
