extends CharacterBody2D

signal enemy_died
signal enemy_pass
signal base_damaged(damage)
signal reward_earned(amount)

@export var speed: float = 50
@export var max_health: float = 10
@export var damage_to_base: int = 1
@export var reward: int = 5

var path_follow: PathFollow2D
var current_health: float
var is_dying: bool = false
var has_been_died = false

func _ready():
	current_health = max_health
	$HealthBar.max_value = max_health
	$HealthBar.value = current_health

func _process(delta):
	if is_dying:
		return
		
	if path_follow:
		path_follow.progress += speed * delta
		global_position = path_follow.global_position
		
		# Rotate tank to follow path direction
		if path_follow.progress_ratio < 0.99:
			# Simpan posisi saat ini
			var current_pos = global_position
			
			# Cek posisi berikutnya di path
			var original_offset = path_follow.progress
			path_follow.progress += 10.0  # Geser sedikit ke depan
			var next_pos = path_follow.global_position
			path_follow.progress = original_offset  # Kembalikan ke posisi asli
			
			# Hitung arah yang benar
			var direction = (next_pos - current_pos).normalized()
			rotation = direction.angle() + PI/2

		if path_follow.progress_ratio >= 1.0:
			# Tank reached end - damage base
			emit_signal("base_damaged", damage_to_base)
			if not has_been_died:
				has_been_died = true
				emit_signal("enemy_died")
			if ResourcesManager:
				ResourcesManager.modify_hp(-damage_to_base)
			queue_free()

func take_damage(damage_amount):
	if is_dying:
		return
		
	current_health -= damage_amount
	$HealthBar.value = current_health
	
	# Flash red when hit
	$Hull.modulate = Color(1.5, 0.5, 0.5)
	$Weapon.modulate = Color(1.5, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	$Hull.modulate = Color(1, 1, 1)
	$Weapon.modulate = Color(1, 1, 1)
	
	if current_health <= 0:
		die()
		
func die():
	is_dying = true
	
	# Disable collision
	$CollisionShape2D.set_deferred("disabled", true)
	
	ResourcesManager.modify_gold(reward)
	
	# Play dying animation
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(func(): 
		emit_signal("reward_earned", reward)
		if not has_been_died:
			has_been_died = true
			emit_signal("enemy_died")
		queue_free()
	)
