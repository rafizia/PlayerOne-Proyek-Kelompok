extends BaseTower
class_name SupportTower

enum SupportType { SLOW, DAMAGE_BOOST }

# Support effect settings
var support_type: SupportType = SupportType.DAMAGE_BOOST
var base_effect_amount: float = 0.2  # 20% slow or 20% damage boost
var current_effect_amount: float = 0.2
var base_radius: float = 100.0
var current_radius: float = 100.0

# Upgrade settings
var effect_multipliers: Array[float] = [1.0, 1.5, 2.0]  # Effect strength multiplier
var radius_increases: Array[float] = [0.0, 30.0, 60.0]  # Additional radius per level
var upgrade_costs: Array[int] = [0, 75, 150]  # Costs for upgrading to level 2, 3

# Effect area
var effect_area: Area2D

# Effect tracking
var affected_enemies = []
var affected_towers = []

func _ready():
	super._ready()  # Call parent _ready function
	
	# Set tower properties
	tower_name = "Support Tower"
	build_cost = 20
	maintenance_cost = 8
	
	# Setup effect area
	setup_effect_area()

func _process(_delta):
	if !is_active:
		return
	
	# Only process if the tower is placed (not being dragged)
	if get_parent().name != "Towers":
		return

# Setup the effect area
func setup_effect_area():
	# Create the area and collision shape
	effect_area = Area2D.new()
	effect_area.name = "EffectArea"
	effect_area.collision_layer = 2  # Layer 2
	effect_area.collision_mask = 18  # Layers 2 (2) and 5 (16)
	var effect_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = current_radius
	effect_shape.shape = circle_shape
	effect_area.add_child(effect_shape)
	
	# Connect signals
	effect_area.connect("body_entered", Callable(self, "_on_effect_area_body_entered"))
	effect_area.connect("body_exited", Callable(self, "_on_effect_area_body_exited"))
	
	add_child(effect_area)

# Update effect radius
func update_effect_radius():
	var circle_shape = effect_area.get_node("CollisionShape2D").shape as CircleShape2D
	circle_shape.radius = current_radius

# Handler when body enters effect area
func _on_effect_area_body_entered(body):
	if !is_active:
		return
	
	# For slow effect (enemies)
	if support_type == SupportType.SLOW and body.is_in_group("enemies"):
		if !affected_enemies.has(body):
			affected_enemies.append(body)
			if body.has_method("apply_slow"):
				body.apply_slow(current_effect_amount)
	
	# For damage boost (other towers)
	elif support_type == SupportType.DAMAGE_BOOST and body.is_in_group("towers"):
		if !affected_towers.has(body):
			affected_towers.append(body)
			if body.has_method("apply_damage_boost"):
				body.apply_damage_boost(current_effect_amount)

# Handler when body exits effect area
func _on_effect_area_body_exited(body):
	# Remove slow effect
	if support_type == SupportType.SLOW and body.is_in_group("enemies"):
		affected_enemies.erase(body)
		if body.has_method("remove_slow"):
			body.remove_slow(current_effect_amount)
	
	# Remove damage boost
	elif support_type == SupportType.DAMAGE_BOOST and body.is_in_group("towers"):
		affected_towers.erase(body)
		if body.has_method("remove_damage_boost"):
			body.remove_damage_boost(current_effect_amount)

# Set support tower type
func set_support_type(type: SupportType):
	support_type = type

# Override update_tower_stats
func update_tower_stats():
	current_effect_amount = base_effect_amount * effect_multipliers[tower_level - 1]
	current_radius = base_radius + radius_increases[tower_level - 1]
	
	# Update the effect area
	update_effect_radius()

# Override get_upgrade_cost
func get_upgrade_cost() -> int:
	if tower_level < max_level:
		return upgrade_costs[tower_level]
	return 0
