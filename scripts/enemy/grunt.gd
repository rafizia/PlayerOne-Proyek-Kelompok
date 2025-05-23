extends CharacterBody2D

signal enemy_died

@export var base_speed: float = 50.0  # Kecepatan tinggi (unit cepat)
@export var health: float = 4      # Health rendah
@export var max_health: float = 4
@export var gold_reward: int = 3      # Reward gold saat dibunuh
@export var base_damage: int = 1       # Damage ke base
@export var attack_range: float = 200.0  # Range attack
@export var attack_damage: float = 5.0   # Damage per serangan
@export var attack_cooldown: float = 2.0 # Waktu antara serangan

var path_follow: PathFollow2D
var current_speed: float
var slow_effects = []
var attack_timer: Timer
var current_target = null
var can_attack = true
var attacking = false
var has_been_died = false

func _ready():
	# Masukkan ke grup enemies agar bisa dideteksi tower
	add_to_group("enemies")
	
	# Set kecepatan awal
	current_speed = base_speed
	
	# Setup health bar
	var health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.show_percentage = false
	health_bar.size = Vector2(50, 6)
	health_bar.position = Vector2(-25, -10)
	add_child(health_bar)
	
	# Setup attack timer
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.wait_time = attack_cooldown
	attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))
	add_child(attack_timer)
	
	# Setup detection area untuk serangan
	var attack_area = Area2D.new()
	attack_area.name = "AttackArea"
	
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = attack_range
	collision_shape.shape = circle_shape
	
	attack_area.add_child(collision_shape)
	attack_area.collision_layer = 0
	attack_area.collision_mask = 2  # Layer untuk towers
	
	# Connect signals
	attack_area.connect("body_entered", Callable(self, "_on_attack_area_body_entered"))
	attack_area.connect("body_exited", Callable(self, "_on_attack_area_body_exited"))
	
	add_child(attack_area)

func _process(delta):
	# Update health bar
	if has_node("HealthBar"):
		$HealthBar.value = health
	
	# Jika sedang attacking, fokus menyerang
	if attacking and current_target:
		# Ubah animasi ke Attack
		$AnimatedSprite2D.play("Attack")
		
		# Rotate to face target
		look_at(current_target.global_position)
		
		# Jika bisa attack, lakukan attack
		if can_attack:
			attack_target()
	elif path_follow:
		# Jika tidak sedang menyerang, ikuti path
		path_follow.progress += current_speed * delta
		path_follow.rotates = false
		global_position = path_follow.global_position
		
		# Rotate to follow path
		#var movement_direction = Vector2(cos(path_follow.rotation), sin(path_follow.rotation))
		#rotation = movement_direction.angle() + PI/2
		
		# Set animasi ke Run
		$AnimatedSprite2D.play("Run")
		
		# Cek apakah sudah sampai di endpoint
		if path_follow.progress_ratio >= 1.0:
			# Deal damage to base
			if ResourcesManager:
				ResourcesManager.modify_hp(-base_damage)
			if not has_been_died:
				has_been_died = true
				emit_signal("enemy_died")
			queue_free()

# Handler saat ada tower di area serangan
func _on_attack_area_body_entered(body):
	# Cek jika body adalah tower
	if body.is_in_group("towers") and body.has_method("take_damage"):
		# Kalau belum ada target atau target lama sudah tidak valid
		if current_target == null or !is_instance_valid(current_target):
			current_target = body
			# Start attacking
			attacking = true

# Handler saat tower keluar area serangan
func _on_attack_area_body_exited(body):
	if body == current_target:
		# Stop attacking
		attacking = false
		current_target = null
		# Set animasi kembali ke Run
		$AnimatedSprite2D.play("Run")
		
		# Cari target baru jika ada
		var towers_in_range = $AttackArea.get_overlapping_bodies()
		for tower in towers_in_range:
			if tower.is_in_group("towers") and tower.has_method("take_damage"):
				current_target = tower
				attacking = true
				break

# Attack tower
func attack_target():
	if !is_instance_valid(current_target):
		attacking = false
		current_target = null
		return
		
	# Set cooldown
	can_attack = false
	attack_timer.start()
	
	# Deal damage
	current_target.take_damage(attack_damage)
	
	# Spawn projectile (visual only)
	spawn_projectile()

# Timer cooldown attack selesai
func _on_attack_timer_timeout():
	can_attack = true

# Spawn projectile visual
func spawn_projectile():
	# Ini bisa dibuat nanti untuk visual peluru
	pass

# Take damage
func take_damage(amount: float) -> bool:
	health -= amount
	
	# Flash merah saat kena damage
	modulate = Color(2.0, 0.5, 0.5)  # Bright red
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)  # Back to normal
	
	if health <= 0:
		die()
		return true
	return false

# Die
func die():
	if not has_been_died:
		has_been_died = true
		emit_signal("enemy_died")
	
	# Berikan gold ke player
	if ResourcesManager:
		ResourcesManager.modify_gold(gold_reward)
	
	queue_free()

# Support tower slow effect implementation
func apply_slow(slow_amount: float):
	slow_effects.append(slow_amount)
	update_speed()
	
	# Visual feedback
	modulate = Color(0.7, 0.9, 1.0)  # Blue tint when slowed

# Remove slow effect
func remove_slow(slow_amount: float):
	slow_effects.erase(slow_amount)
	update_speed()
	
	# Remove visual feedback if no longer slowed
	if slow_effects.is_empty():
		modulate = Color(1, 1, 1)  # Reset to normal

# Update speed with all slow effects
func update_speed():
	var total_slow = 0.0
	
	for effect in slow_effects:
		total_slow += effect
	
	# Cap at 80% slow
	total_slow = min(total_slow, 0.8)
	
	# Apply slow to speed
	current_speed = base_speed * (1.0 - total_slow)
