extends Panel

@export var tower_scene: PackedScene

@onready var tower_placer = TowerPlacerManager

@export var build_cost: int = 15  # Default value, you can change this in the inspector

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				if tower_placer.start_tower_placement(tower_scene, build_cost):
					# Successfully started placement
					pass
			else:
				# End dragging
				tower_placer.end_tower_placement()
	elif event is InputEventMouseMotion and event.button_mask == 1:  # 1 is left mouse button mask
		# Update tower position while dragging
		tower_placer.update_tower_position(event.global_position) 
