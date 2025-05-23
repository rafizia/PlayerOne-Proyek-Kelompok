extends Panel

@export var tower_scene: PackedScene

@onready var tower_placer = TowerPlacerManager
@onready var build_cost_label = $VBoxContainer/MarginContainer/HBoxContainer/BuildCostLabel

var build_cost: int = 0
var is_affordable: bool = true

func _ready():
	# Get the build cost from the label
	build_cost = int(build_cost_label.text)
	
	# Connect to resource manager's signal
	if ResourcesManager._instance:
		ResourcesManager._instance.connect("resources_updated", Callable(self, "_on_resources_updated"))
	
	# Connect to tower placer's signal
	if tower_placer:
		tower_placer.connect("tower_placement_ended", Callable(self, "_on_tower_placement_ended"))
	
	# Initial check
	check_affordability()

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

func _on_resources_updated(energy, gold, hp):
	check_affordability()

func _on_tower_placement_ended(tower_instance, success):
	# Update panel appearance when tower placement ends (whether successful or not)
	check_affordability()

func check_affordability():
	if ResourcesManager._instance:
		is_affordable = ResourcesManager._instance.gold >= build_cost
		update_visuals()

func update_visuals():
	if is_affordable:
		modulate = Color(1, 1, 1)  # Normal color
	else:
		modulate = Color(0.5, 0.5, 0.5)  # Darker color 
