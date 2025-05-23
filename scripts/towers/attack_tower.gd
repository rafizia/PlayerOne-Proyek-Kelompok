extends BaseTower
class_name AttackTower

# Tower properties
@export var attack_tower_name: String = "Attack Tower"
@export var attack_tower_build_cost: int = 15
@export var attack_tower_maintenance_cost: int = 5

# Combat properties
@export var bullet_scene: PackedScene
@export var base_bullet_speed: float = 500
@export var base_bullet_damage: float = 1
@export var base_range_radius: float = 120
@export var base_reload_time: float = 0.5

# Simplified upgrade parameters
@export var range_upgrade_add: float = 15    # +15 increase per level
@export var damage_upgrade_add: float = 2        # +2 damage per level
@export var reload_upgrade_reduce: float = 0.1   # -0.1s per level
@export var upgrade_cost_base: int = 50          # Cost increases by 75 each level

# Runtime arrays (auto-generated)
var range_additions: Array[float] = []
var damage_additions: Array[float] = []
var reload_reductions: Array[float] = []
var upgrade_costs: Array[int] = []

# Current stats
var current_bullet_speed: float
var current_bullet_damage: float
var base_damage: float  # Store base damage separately from boosted damage
var current_range_radius: float
var current_reload_time: float

var enemies_in_range: Array = []
var current_target: Node2D = null

@onready var aim: Marker2D = $Muzzle/Aim
@onready var detection_area: Area2D = $EffectArea
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var animated_sprite: AnimatedSprite2D = $Muzzle


func _ready():
	super._ready()

	# Set tower properties
	tower_name = attack_tower_name
	build_cost = attack_tower_build_cost
	maintenance_cost = attack_tower_maintenance_cost
	
	_build_upgrade_arrays()
	initialize_stats()
	update_detection_area()

func _build_upgrade_arrays():
	range_additions = [0.0]
	damage_additions = [0.0]
	reload_reductions = [0.0]
	upgrade_costs = [0]
	
	for level in range(1, max_level + 1):
		# Range: linear addition (0, +15, +30)
		range_additions.append(range_upgrade_add * level)
		
		# Damage: linear addition (0, +2, +4)
		damage_additions.append(damage_upgrade_add * level)
		
		# Reload: linear reduction (0, -0.1, -0.2)
		reload_reductions.append(reload_upgrade_reduce * level)
		
		# Costs: linear increase (75, 150)
		upgrade_costs.append(upgrade_cost_base * level)
	
func initialize_stats():
	current_bullet_speed = base_bullet_speed
	current_bullet_damage = base_bullet_damage
	base_damage = base_bullet_damage  # Initialize base damage
	current_range_radius = base_range_radius
	current_reload_time = base_reload_time
	cooldown_timer.wait_time = current_reload_time

func update_detection_area():
	if not is_instance_valid(detection_area):
		return

	var collision_shape = detection_area.get_node_or_null("CollisionShape2D")
	if not collision_shape:
		return

	var circle_shape = collision_shape.shape
	
	if circle_shape is CircleShape2D:
		circle_shape.radius = current_range_radius

func _process(delta):
	if not is_active:
		return
	
	# Only process if the tower is placed (not being dragged)
	if get_parent().name != "Towers":
		return
	
	enemies_in_range = enemies_in_range.filter(func(enemy): 
		return is_instance_valid(enemy) and enemy.is_inside_tree()
	)
	
	if enemies_in_range.size() > 0:
		# Find enemy furthest along the path
		enemies_in_range.sort_custom(func(a, b): 
			return a.get_parent().progress > b.get_parent().progress
		)
		current_target = enemies_in_range[0]
		get_node("Muzzle").look_at(current_target.global_position)
		
		if cooldown_timer.is_stopped():
			shoot()
			cooldown_timer.start()
	else:
		current_target = null

func shoot():
	if not bullet_scene or not current_target:
		return
	
	animated_sprite.play("shoot")
	var bullet = bullet_scene.instantiate()
	var spawn_pos = aim.global_position
	get_parent().add_child(bullet)
	bullet.global_position = spawn_pos
	bullet.setup(
		current_target,
		current_bullet_damage,
		current_bullet_speed,
		spawn_pos
	)	
	
func _on_muzzle_animation_finished() -> void:
	animated_sprite.stop()

func _on_detection_area_body_entered(body):
	if body.is_in_group("enemies") and is_active:
		enemies_in_range.append(body)

func _on_detection_area_body_exited(body):
	if body in enemies_in_range:
		enemies_in_range.erase(body)

# Upgrade implementation
func get_upgrade_cost() -> int:
	if tower_level < max_level:
		return upgrade_costs[tower_level]
	return 0

func update_tower_stats():
	current_range_radius = base_range_radius + range_additions[tower_level - 1]
	base_damage = base_bullet_damage + damage_additions[tower_level - 1]
	current_bullet_damage = base_damage  # Reset to base damage before applying any boosts
	
	if has_meta("support_boost"):
		var boost_amount = get_meta("support_boost")
		current_bullet_damage = base_damage * (1.5 + boost_amount)
	
	current_reload_time = base_reload_time - reload_reductions[tower_level - 1]
	
	# Update components
	update_detection_area()
	cooldown_timer.wait_time = current_reload_time

func _on_cooldown_timer_timeout():
	cooldown_timer.stop()

# Support tower interaction methods
func apply_damage_boost(boost_amount: float):
	# Apply damage boost as a multiplier
	current_bullet_damage = base_damage * (1.5 + boost_amount)
	set_meta("support_boost", boost_amount)

func remove_damage_boost(boost_amount: float):
	# Remove damage boost and return to base damage
	current_bullet_damage = base_damage
	remove_meta("support_boost")
	
func _physics_process(delta: float) -> void:
	pass
	
func turn():
	var enemy_position = get_global_mouse_position()
	get_node("Muzzle").look_at(enemy_position)
