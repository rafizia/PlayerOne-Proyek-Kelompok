extends BaseTower
class_name ResourceTower

# Resource generation settings
var base_generation_rate: float = 0.5  # Energy per second
var current_generation_rate: float = 0.5

# Upgrade settings
var generation_multipliers: Array[float] = [1.0, 1.75, 2.5]  # Level 1, 2, 3 multipliers
var upgrade_costs: Array[int] = [0, 50, 100]  # Costs for upgrading to level 2, 3

func _ready():
	super._ready()  # Call parent _ready function
	
	# Set tower properties
	tower_name = "Resource Tower"
	build_cost = 15
	maintenance_cost = 5

func _process(delta):
	# Only generate resources if tower is active
	if is_active:
		var generated = current_generation_rate * delta
		if ResourcesManager._instance:
			ResourcesManager._instance.energy = min(
				ResourcesManager._instance.MAX_ENERGY,
				ResourcesManager._instance.energy + generated
			)

# Override update_tower_stats
func update_tower_stats():
	# Update generation rate based on level
	current_generation_rate = base_generation_rate * generation_multipliers[tower_level - 1]

# Override get_upgrade_cost
func get_upgrade_cost() -> int:
	if tower_level < max_level:
		return upgrade_costs[tower_level]
	return 0
