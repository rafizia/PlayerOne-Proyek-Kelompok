extends CharacterBody2D

signal enemy_died

@export var base_speed: float = 40.0  # Kecepatan lambat (heavy tank)
@export var health: float = 300.0     # Health tinggi
@export var max_health: float = 300.0
@export var gold_reward: int = 35     # Reward gold saat dibunuh
@export var base_damage: int = 3      # Damage ke base (lebih tinggi dari tank biasa)
@export var damage_reduction: float = 0.75  # Reduksi damage saat defense mode (terima 25% damage)
@export var defense_duration: float = 5.0   # Durasi defense mode
@export var defense_cooldown: float = 15.0  # Cooldown defense mode

var path_follow: PathFollow2D
var current_speed: float
var slow_effects = []
var defense_active = false
var can_defense = true

func _ready():
    # Set kecepatan awal
    current_speed = base_speed
    
    # Setup health bar
    if has_node("HealthBar"):
        $HealthBar.max_value = max_health
        $HealthBar.value = health
    
    # Setup timer untuk defense mode
    var defense_timer = Timer.new()
    defense_timer.name = "DefenseTimer"
    defense_timer.one_shot = true
    defense_timer.wait_time = defense_duration
    defense_timer.connect("timeout", Callable(self, "_on_defense_end"))
    add_child(defense_timer)
    
    # Setup timer untuk defense cooldown
    var cooldown_timer = Timer.new()
    cooldown_timer.name = "CooldownTimer"
    cooldown_timer.one_shot = true
    cooldown_timer.wait_time = defense_cooldown
    cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_end"))
    add_child(cooldown_timer)
    
    # Mulai defense mode jika diserang
    await get_tree().create_timer(3.0).timeout
    
    # Aktifkan defense mode pertama kali setelah beberapa saat dalam permainan
    if randf() < 0.7: # 70% chance to activate initially
        activate_defense()

func _process(delta):
    if path_follow:
        path_follow.progress += current_speed * delta
        global_position = path_follow.global_position
        
        # Update health bar
        if has_node("HealthBar"):
            $HealthBar.value = health
            $ShieldIndicator.visible = defense_active
        
        # Rotate to follow path direction
        var movement_direction = Vector2(cos(path_follow.rotation), sin(path_follow.rotation))
        rotation = movement_direction.angle() + PI/2

        if path_follow.progress_ratio >= 1.0:
            # Tank mencapai endpoint - berikan damage extra ke base
            if ResourcesManager:
                ResourcesManager.modify_hp(-base_damage)
            emit_signal("enemy_died")
            queue_free()

# Aktifkan defense mode
func activate_defense():
    if !can_defense or defense_active:
        return
    
    defense_active = true
    can_defense = false
    current_speed *= 0.5  # Kurangi speed selama defense mode
    
    # Visual effect untuk defense mode
    modulate = Color(0.5, 0.8, 1.2)  # Blue shield glow
    
    # Efek shield
    $ShieldIndicator.visible = true
    
    # Start defense timer
    $DefenseTimer.start()

# Defense mode berakhir
func _on_defense_end():
    defense_active = false
    current_speed = base_speed
    update_speed()  # Terapkan kembali efek slow jika ada
    
    # Remove visual effect
    modulate = Color(1, 1, 1)
    $ShieldIndicator.visible = false
    
    # Start cooldown
    $CooldownTimer.start()

# Cooldown berakhir
func _on_cooldown_end():
    can_defense = true

# Terima damage - dengan defense mode
func take_damage(amount: float) -> bool:
    # Jika defense mode aktif, reduksi damage
    var actual_damage = amount
    if defense_active:
        actual_damage *= damage_reduction
    
    health -= actual_damage
    
    # Flash merah saat kena damage (lebih sedikit jika defense aktif)
    if defense_active:
        modulate = Color(1.25, 1.0, 1.5)  # Purple-ish untuk shield hit
    else:
        modulate = Color(2.0, 0.5, 0.5)  # Bright red untuk hit biasa
    
    await get_tree().create_timer(0.1).timeout
    
    if defense_active:
        modulate = Color(0.5, 0.8, 1.2)  # Kembali ke warna defense
    else:
        modulate = Color(1, 1, 1)  # Kembali ke normal
        
    # Jika belum aktif defense dan health turun terlalu banyak, aktifkan defense
    if !defense_active and can_defense and health < max_health * 0.5:
        activate_defense()
        
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
    
    queue_free()

# Support tower slow effect implementation
func apply_slow(slow_amount: float):
    slow_effects.append(slow_amount)
    update_speed()

func remove_slow(slow_amount: float):
    slow_effects.erase(slow_amount)
    update_speed()

func update_speed():
    var total_slow = 0.0
    for effect in slow_effects:
        total_slow += effect
    
    # Cap slow at 80%
    total_slow = min(total_slow, 0.8)
    
    # Apply slow effect to current speed
    var modifier = 0.5 if defense_active else 1.0  # Half speed if defense active
    current_speed = base_speed * (1.0 - total_slow) * modifier