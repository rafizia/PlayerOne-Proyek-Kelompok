extends Node2D

@onready var path := $Path2D
@onready var path2 := $Path2D2
@onready var timer := $Timer
@export var spawn_delay := 1.0
@onready var hp_label = $Level_UI/Health/HPLabel
@onready var wave_label = $Level_UI/Waves/WaveLabel
@onready var coin_label = $Level_UI/Coin/CoinLabel
@onready var energy_label = $Level_UI/Energy/EnergyLabel
@onready var win_screen = $WinScreen
@onready var win_screen_continue = $WinScreen/TextureRect/Continue
@onready var game_over = $GameOver
@onready var restart_button = $GameOver/TextureRect/Restart
@onready var start_battle = $StartBattleIcon
@onready var restart_button_pause = $PauseScreen/TextureRect/Restart

var hp = ResourcesManager.hp
var remaining_enemies = 0
var current_wave = 0
var enemy_queue: Array = []
var is_game_over_handled := false

var wave_data = [
	[ 	# Wave 1
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1}
	],
	[	# Wave 2
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank1.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank1.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1}
	],
	[	# Wave 3
		{"scene": preload("res://scenes/enemy/tank1.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank1.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank1.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank1.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank1.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/flyer.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/flyer.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 2}
	],
	[	# Wave 4
		{"scene": preload("res://scenes/enemy/tank1.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank1.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank1.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank1.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 2}
	],
	[	# Wave 5
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/grunt.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank1.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank1.tscn"), "path": 2},
		
	],
	[	# Wave 6
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank2.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank3.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank3.tscn"), "path": 1},
	],
	[	# Wave 7
		{"scene": preload("res://scenes/enemy/tank3.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank3.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank3.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank3.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/tank3.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank3.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/tank3.tscn"), "path": 1},
		{"scene": preload("res://scenes/enemy/flyer.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/flyer.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/flyer.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/flyer.tscn"), "path": 2},
		{"scene": preload("res://scenes/enemy/flyer.tscn"), "path": 2}
	]
]

@export var bgm : AudioStreamMP3
@export var runbgm : AudioStreamMP3
@export var winbgm : AudioStreamMP3
@export var losebgm : AudioStreamMP3

func _ready():
	wave_label.text = "Wave 1/7"
	win_screen_continue.level_path = "res://scenes/Levels/level3.tscn"
	restart_button.level_path = "res://scenes/Levels/level2.tscn"
	restart_button_pause.level_path = "res://scenes/Levels/level2.tscn"
	
func get_bgm():
	return bgm

func _process(delta):
	hp_label.text = str(ResourcesManager.hp)
	coin_label.text = str(ResourcesManager.gold)
	energy_label.text = str(int(ResourcesManager.energy))
	
	if (ResourcesManager.hp <= 0 or ResourcesManager.energy <= 0) and not is_game_over_handled:
		is_game_over_handled = true
		game_over.visible = true
		SoundManager.play_bgm(losebgm, false, false)
		get_tree().paused = true
	
func start_wave():
	enemy_queue.clear()

	if current_wave == 0:
		SoundManager.play_bgm(runbgm,true)

	if current_wave >= wave_data.size() and remaining_enemies == 0:
		SoundManager.play_bgm(winbgm, false, false)
		print("Semua wave selesai!")
		win_screen.visible = true
		get_tree().paused = true
		return

	# Tambah semua musuh dalam antrian spawn
	enemy_queue = wave_data[current_wave].duplicate()	

	wave_label.text = "Wave %d/7" % (current_wave + 1)
	remaining_enemies = enemy_queue.size()
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
	path_follow.add_child(enemy)

	enemy.path_follow = path_follow
	enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))

func _on_enemy_died():
	remaining_enemies -= 1
	print("sisa musuh:", remaining_enemies)
	if remaining_enemies == 0:
		print("Wave %d selesai!" % (current_wave))	
		if current_wave != wave_data.size():
			start_battle.visible = true	
		else:
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
