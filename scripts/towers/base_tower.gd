class_name BaseTower
extends StaticBody2D

# Tower properties
var tower_name: String = "Base Tower"
var tower_level: int = 1
var max_level: int = 3
var is_active: bool = true
var build_cost: int = 10  # Energy cost to build
var maintenance_cost: int = 1  # Energy per minute

# Signal
signal tower_activated()
signal tower_deactivated()
signal tower_upgraded(new_level)

func _ready():
    # Register tower with ResourcesManager when created
    if ResourcesManager:
        ResourcesManager.register_tower(self)

func _exit_tree():
    # Unregister tower when removed
    if ResourcesManager:
        ResourcesManager.unregister_tower(self)

# Toggle active state
func toggle_active() -> bool:
    is_active = !is_active
    
    if is_active:
        $AnimatedSprite2D.play()
        emit_signal("tower_activated")
    else:
        $AnimatedSprite2D.stop()
        emit_signal("tower_deactivated")
    
    return is_active

# Upgrade tower
func upgrade() -> bool:
    if tower_level >= max_level:
        return false
        
    var upgrade_cost = get_upgrade_cost()
    if ResourcesManager.spend_gold(upgrade_cost):
        tower_level += 1
        update_tower_stats()
        emit_signal("tower_upgraded", tower_level)
        return true
    
    return false

# Get the upgrade cost (to be overridden)
func get_upgrade_cost() -> int:
    return 50 * tower_level

# Update tower stats after upgrade (to be overridden)
func update_tower_stats():
    pass