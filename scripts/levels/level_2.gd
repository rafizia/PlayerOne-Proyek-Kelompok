extends Node2D

@onready var path := $Path2D
@onready var path2 := $Path2D2
@onready var timer := $Timer
@export var spawn_delay := 1.0
@onready var hp_label = $UI/Health/HPLabel
@onready var wave_label = $UI/Waves/WaveLabel

var hp := 10
var remaining_enemies = 0
var current_wave = 0
var enemy_queue: Array = []

var wave_data = [
	[ 	# Wave 1
		{"scene": preload("res://scenes/enemy/tank1.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank1.tscn"), "path": 1}
	],
	[	# Wave 2
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank1.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 2}
	],
	[	# Wave 3
		{"scene": preload("res://scenes/enemy/tank3.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 1}
	]
]

func _ready():
	start_wave()
	
func start_wave():
	enemy_queue.clear()

	if current_wave >= wave_data.size():
		print("Semua wave selesai!")
		return

	# Tambah semua musuh dalam antrian spawn
	enemy_queue = wave_data[current_wave].duplicate()	

	wave_label.text = "Wave %d/5" % (current_wave + 1)
	print("Wave %d: %d musuh" % [current_wave + 1, enemy_queue.size()])
	timer.wait_time = spawn_delay
	timer.start()
	
func spawn_enemy(enemy_scene: PackedScene, path_id: int):
	var selected_path: Path2D
	if path_id == 1:
		selected_path = path
	else:
		selected_path = path2
		
	var path_follow = PathFollow2D.new()
	path_follow.loop = false
	selected_path.add_child(path_follow)

	var enemy = enemy_scene.instantiate()
	remaining_enemies += 1
	path_follow.add_child(enemy)

	enemy.path_follow = path_follow
	enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))

func _on_enemy_died():
	decrease_hp()
	remaining_enemies -= 1
	if remaining_enemies == 0:
		print("Wave %d selesai!" % (current_wave))		
		await get_tree().create_timer(2.0).timeout
		start_wave()

func _on_timer_timeout() -> void:
	if enemy_queue.is_empty():
		timer.stop()
		current_wave += 1
		return

	var enemy_info = enemy_queue.pop_front()
	var enemy_scene = enemy_info["scene"]
	var path_id = enemy_info["path"]
	spawn_enemy(enemy_scene, path_id)
	timer.start() 
	
func decrease_hp():
	hp -= 1
	hp_label.text = "%d" % hp
	if hp <= 0:
		game_over()

func game_over():
	print("Game Over!")
