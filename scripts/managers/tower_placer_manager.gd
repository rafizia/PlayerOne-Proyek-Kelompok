extends Node

# Signals
signal tower_placement_started(tower_instance)
signal tower_placement_ended(tower_instance, success)

# References
var current_tower: Node2D = null
var is_dragging: bool = false
var can_place: bool = false

# Tower placement settings
var level_path: String = "Level1"  # Default to Level1
var tilemap_layers: Array = []

var holdsfx: AudioStreamPlayer


func _ready():
	# Wait for the scene to be ready
	await get_tree().process_frame
	initialize_level()

func initialize_level():
	# Get the current level number from the scene name
	var scene_name = get_tree().current_scene.name
	if scene_name.begins_with("Level"):
		var level_number = scene_name.substr(5)  # Get the number after "Level"
		set_level(int(level_number))

# Function to set the current level
func set_level(level_number: int) -> void:
	level_path = "Level" + str(level_number)
	# Get all TileMap layers when level is set
	var tilemap = get_tree().get_root().get_node(level_path + "/TileMap")
	if tilemap:
		tilemap_layers = tilemap.get_children()
		# Sort layers to ensure Base is first
		tilemap_layers.sort_custom(func(a, b): return a.name == "Base")

func is_valid_tile_placement(tile_pos: Vector2i) -> bool:
	if tilemap_layers.is_empty():
		return false
		
	# Check if tile exists in base layer
	var base_layer = tilemap_layers[0]
	var base_cell = base_layer.get_cell_source_id(tile_pos)
	if base_cell == -1:  # Not in base layer
		return false
		
	# Check if tile exists in any other layer
	for i in range(1, tilemap_layers.size()):
		var layer = tilemap_layers[i]
		var cell = layer.get_cell_source_id(tile_pos)
		if cell != -1:  # Found in another layer
			return false
			
	return true

func start_tower_placement(tower_scene: PackedScene, cost: int) -> bool:
	# Check if player has enough resources
	if not ResourcesManager._instance.spend_gold(cost):
		return false
	
	# Instantiate the tower
	current_tower = tower_scene.instantiate()
	get_tree().current_scene.add_child(current_tower)
	
	is_dragging = true
	emit_signal("tower_placement_started", current_tower)
	holdsfx = SoundManager.play_hold()
	return true

func update_tower_position(position: Vector2) -> void:
	if not is_dragging or not current_tower:
		return
	
	# Get the mouse position in screen coordinates
	var viewport = get_tree().get_root()
	var mouse_pos = viewport.get_mouse_position()
	
	# Use the base layer to convert mouse position to tile coordinates
	if not tilemap_layers.is_empty():
		var base_layer = tilemap_layers[0]
		
		# Convert screen coordinates to TileMap local coordinates
		var camera = get_tree().get_root().get_node(level_path + "/Camera2D")
		if camera:
			# Convert screen position to global position using the camera
			var global_pos = camera.get_screen_center_position() - (camera.get_viewport_rect().size / 2) + mouse_pos
			# Convert global position to TileMap local position
			var local_pos = base_layer.to_local(global_pos)
			# Convert local position to tile coordinates
			var tile = base_layer.local_to_map(local_pos)
			
			# Update tower position to match the tile center
			var tile_center = base_layer.map_to_local(tile)
			current_tower.global_position = base_layer.to_global(tile_center)
			
			# Check if on valid tile and no other tower is in the way
			var tower_detector = current_tower.get_node("TowerDetector")
			var overlapping_bodies = tower_detector.get_overlapping_bodies()
			
			# Check both tile placement validity and overlapping bodies
			can_place = is_valid_tile_placement(tile) and (overlapping_bodies.size() <= 1)  # 1 because it detects itself
			
			# Update visual feedback
			var area = current_tower.get_node_or_null("Area")
			if area:
				if can_place:
					area.modulate = Color(0, 255, 0)  # Green
				else:
					area.modulate = Color(255, 0, 0)  # Red
			else:
				# For towers without Area node, modify the tower's modulate directly
				if can_place:
					current_tower.modulate = Color(0, 255, 0, 0.5)
				else:
					current_tower.modulate = Color(255, 0, 0, 0.5)

func end_tower_placement() -> void:
	if holdsfx:
		holdsfx.stop()
	
	if not is_dragging or not current_tower:
		return
	
	if can_place:
		# Move tower to the Towers node
		var towers_node = get_tree().get_root().get_node(level_path + "/Towers")
		current_tower.reparent(towers_node)
		var area = current_tower.get_node_or_null("Area")

		if area:
			area.hide()

		current_tower.modulate = Color(1, 1, 1)
		SoundManager.play_place()
		emit_signal("tower_placement_ended", current_tower, true)
	else:
		# Refund the cost and remove the tower
		ResourcesManager._instance.gold += current_tower.build_cost
		current_tower.queue_free()
		emit_signal("tower_placement_ended", current_tower, false)
	
	current_tower = null
	is_dragging = false
	can_place = false
