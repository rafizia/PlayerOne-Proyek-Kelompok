extends Node2D
class_name BaseTower

# Tower properties
var tower_name: String = "Base Tower"
var tower_level: int = 1
var max_level: int = 3
var build_cost: int = 0
var maintenance_cost: int = 0
var is_active: bool = true

# Called when the node enters the scene tree for the first time
func _ready():
	add_to_group("towers")

# Tower activation/deactivation
func set_active(active: bool):
	is_active = active

# To be overridden by child classes
func update_tower_stats():
	pass

# To be overridden by child classes
func get_upgrade_cost() -> int:
	return 0

# Upgrade tower if possible
func upgrade() -> bool:
	if tower_level < max_level:
		tower_level += 1
		update_tower_stats()
		return true
	return false
