extends CharacterBody2D

signal enemy_died

@export var base_speed: float = 75.0  # Kecepatan dasar (medium)
@export var health: float = 150.0     # Health (medium)
@export var max_health: float = 150.0
@export var gold_reward: int = 20     # Reward gold saat dibunuh
@export var boost_multiplier: float = 2.0  # Pengali kecepatan saat boost
@export var boost_duration: float = 3.0    # Durasi boost dalam detik
@export var boost_cooldown: float = 10.0   # Cooldown boost dalam detik

var path_follow: PathFollow2D
var current_speed: float
var slow_effects = []
var slow_resistance = 0.5  # Resistance terhadap efek slow (hanya 50% efektif)
var can_boost = true
var is_boosting = false

func _ready():
    # Set kecepatan awal
    current_speed = base_speed
    
    # Setup timer untuk boost cooldown
    var boost_timer = Timer.new()
    boost_timer.name = "BoostTimer"
    boost_timer.one_shot = true
    boost_timer.wait_time = boost_duration
    boost_timer.connect("timeout", Callable(self, "_on_boost_end"))
    add_child(boost_timer)
    
    # Setup timer untuk boost cooldown
    var cooldown_timer = Timer.new()
    cooldown_timer.name = "CooldownTimer"
    cooldown_timer.one_shot = true
    cooldown_timer.wait_time = boost_cooldown
    cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_end"))
    add_child(cooldown_timer)
    
    # Mulai boost jika di jalur path1
    if path_follow:
        var path2d = path_follow.get_parent()
        if path2d.name == "Path2D":
            # Tank ada di jalur utama, aktifkan boost di posisi tengah jalur
            await get_tree().create_timer(5.0).timeout
            activate_boost()

func _process(delta):
    if path_follow:
        path_follow.progress += current_speed * delta
        global_position = path_follow.global_position

        # Update health bar
        if has_node("HealthBar"):
            $HealthBar.value = health
            $BoostIndicator.visible = is_boosting
        
        # Rotate to follow path direction
        var movement_direction = Vector2(cos(path_follow.rotation), sin(path_follow.rotation))
        rotation = movement_direction.angle() + PI/2

        if path_follow.progress_ratio >= 1.0:
            emit_signal("enemy_died")
            queue_free()

# Aktifkan boost kecepatan
func activate_boost():
    if !can_boost or is_boosting:
        return
    
    is_boosting = true
    can_boost = false
    current_speed = base_speed * boost_multiplier
    
    # Visual effect for boost
    modulate = Color(1.5, 1.0, 0.5)  # Orange-ish glow
    
    # Particle effect kan dibuat nanti
    
    # Start boost timer
    $BoostTimer.start()

# Boost berakhir
func _on_boost_end():
    is_boosting = false
    current_speed = base_speed
    update_speed()  # Terapkan kembali efek slow jika ada
    
    # Remove visual effect
    modulate = Color(1, 1, 1)
    
    # Start cooldown
    $CooldownTimer.start()

# Cooldown berakhir
func _on_cooldown_end():
    can_boost = true

# Terima damage
func take_damage(amount: float) -> bool:
    health -= amount
    
    # Flash merah saat kena damage
    modulate = Color(2.0, 0.5, 0.5)  # Bright red
    await get_tree().create_timer(0.1).timeout
    
    if is_boosting:
        modulate = Color(1.5, 1.0, 0.5)  # Back to boost color
    else:
        modulate = Color(1, 1, 1)  # Back to normal
        
    if health <= 0:
        die()
        return true
    return false

# Mati dan berikan reward
func die():
    emit_signal("enemy_died")
    
    # Berikan gold ke player
    if ResourcesManager:
        ResourcesManager.modify_gold(gold_reward)
    
    # Efek kematian bisa ditambahkan nanti
    queue_free()

# Support tower slow effect implementation
func apply_slow(slow_amount: float):
    # Tank 2 has slow resistance
    slow_effects.append(slow_amount * slow_resistance)
    update_speed()

func remove_slow(slow_amount: float):
    # Need to remove the resisted amount
    slow_effects.erase(slow_amount * slow_resistance)
    update_speed()

func update_speed():
    # Skip if boosting
    if is_boosting:
        return
        
    var total_slow = 0.0
    for effect in slow_effects:
        total_slow += effect
    
    # Cap slow at 80%
    total_slow = min(total_slow, 0.8)
    
    current_speed = base_speed * (1.0 - total_slow)