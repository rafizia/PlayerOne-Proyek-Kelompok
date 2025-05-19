extends Node

class_name ResourcesManager

# Game resources
var energy: float = 100.0
var gold: int = 100
var hp: int = 20

# Resource limits
const MAX_ENERGY: float = 999.0
const MAX_GOLD: int = 999
const MAX_HP: int = 100

# Resource decay settings
var energy_decay_rate: float = 0.2  # Energy lost per second

# Signals
signal resources_updated(energy, gold, hp)
signal game_over(reason)

# Tower tracking
var active_towers = []

# Singleton instance
static var _instance = null

static func _get_instance():
	return _instance

func _init():
	if _instance != null:
		push_error("ResourcesManager already exists!")
		return
	_instance = self

static func register_tower(tower):
	if _get_instance():
		_get_instance().active_towers.append(tower)

static func unregister_tower(tower):
	if _get_instance():
		_get_instance().active_towers.erase(tower)

static func spend_energy(amount: float) -> bool:
	if _get_instance():
		return _get_instance()._spend_energy(amount)
	return false

static func spend_gold(amount: int) -> bool:
	if _get_instance():
		return _get_instance()._spend_gold(amount)
	return false
	
func _spend_energy(amount: float) -> bool:
	if energy >= amount:
		energy -= amount
		emit_signal("resources_updated", energy, gold, hp)
		return true
	return false

func _spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		emit_signal("resources_updated", energy, gold, hp)
		return true
	return false

static func modify_gold(amount: int) -> bool:
    if _get_instance():
        return _get_instance()._modify_gold(amount)
    return false
    
func _modify_gold(amount: int) -> bool:
    gold = clamp(gold + amount, 0, MAX_GOLD)
    emit_signal("resources_updated", energy, gold, hp)
    return true

static func modify_hp(amount: int) -> bool:
    if _get_instance():
        return _get_instance()._modify_hp(amount)
    return false
    
func _modify_hp(amount: int) -> bool:
    hp = clamp(hp + amount, 0, MAX_HP)
    emit_signal("resources_updated", energy, gold, hp)
    
    if hp <= 0:
        emit_signal("game_over", "base_destroyed")
        return false
    return true

func _process(delta):
	# Apply energy decay
	energy = max(0, energy - (energy_decay_rate * delta))
	
	# Check for maintenance costs (simplified - once per second)
	if Engine.get_frames_drawn() % int(Engine.get_frames_per_second()) == 0:
		# Apply maintenance costs for active towers
		var maintenance_cost_per_second = 0.0
		for tower in active_towers:
			if tower.is_active:
				maintenance_cost_per_second += tower.maintenance_cost / 60.0  # Convert from per minute to per second
		
		energy = max(0, energy - maintenance_cost_per_second)
	
	# Check for game over
	if energy <= 0:
		emit_signal("game_over", "energy_depleted")
	
	if hp <= 0:
		emit_signal("game_over", "base_destroyed")
