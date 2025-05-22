extends Node2D

@onready var path := $Path2D
@onready var timer := $Timer
@onready var hp_label := $Level_UI/Health/HPLabel
@onready var wave_label := $Level_UI/Waves/WaveLabel
@onready var coin_label = $Level_UI/Coin/CoinLabel
@onready var energy_label = $Level_UI/Energy/EnergyLabel
@onready var win_screen = $WinScreen
@onready var win_screen_continue = $WinScreen/TextureRect/Continue
@onready var game_over = $GameOver
@onready var restart_button = $GameOver/TextureRect/Restart
@onready var start_battle = $StartBattleIcon
@onready var restart_button_pause = $PauseScreen/TextureRect/Restart

@export var spawn_delay := 1.0
var hp := 15
var current_wave := 0
var remaining_enemies := 0
var enemy_queue := []
var is_game_over_handled := false

var wave_data = [
	[ {"scene": preload("res://scenes/enemy/tank1.tscn") }, {"scene": preload("res://scenes/enemy/tank1.tscn") } ],
	[ {"scene": preload("res://scenes/enemy/tank1.tscn") }, {"scene": preload("res://scenes/enemy/tank1.tscn") }, {"scene": preload("res://scenes/enemy/tank1.tscn") } ],
	[ {"scene": preload("res://scenes/enemy/tank1.tscn") }, {"scene": preload("res://scenes/enemy/tank2.tscn") } ],
	[ {"scene": preload("res://scenes/enemy/tank2.tscn") }, {"scene": preload("res://scenes/enemy/tank1.tscn") }, {"scene": preload("res://scenes/enemy/tank2.tscn") } ],
	[ {"scene": preload("res://scenes/enemy/tank2.tscn") }, {"scene": preload("res://scenes/enemy/tank2.tscn") }, {"scene": preload("res://scenes/enemy/tank1.tscn") } ]
]

@export var bgm : AudioStreamMP3
@export var runbgm : AudioStreamMP3
@export var winbgm : AudioStreamMP3
@export var losebgm : AudioStreamMP3

func _ready():
	# initialize UI and timer
	wave_label.text = "Wave 1/%d" % wave_data.size()
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	
	win_screen_continue.level_path = "res://scenes/Levels/level2.tscn"
	restart_button.level_path = "res://scenes/Levels/level1.tscn"
	restart_button_pause.level_path = "res://scenes/Levels/level1.tscn"
	
	# DO NOT start waves automatically
	# The start_wave will be called by the start_battle button

func get_bgm():
	return bgm

func _process(delta):
	hp_label.text = str(ResourcesManager.hp)
	coin_label.text = str(ResourcesManager.gold)
	energy_label.text = str(int(ResourcesManager.energy))
	
	if (ResourcesManager.hp <= 0 or ResourcesManager.energy <= 0) and not is_game_over_handled:
    SoundManager.play_bgm(losebgm, false, false)
		is_game_over_handled = true
		game_over.visible = true
		get_tree().paused = true
    
func start_wave():
	enemy_queue.clear()
	if current_wave == 0:
		SoundManager.play_bgm(runbgm,true)
	if current_wave >= wave_data.size():
		SoundManager.play_bgm(winbgm, false, false)
		print("Semua wave selesai!")
		win_screen.visible = true
		get_tree().paused = true
		return
	# queue wave
	enemy_queue = wave_data[current_wave].duplicate()
	wave_label.text = "Wave %d/%d" % [current_wave + 1, wave_data.size()]
	remaining_enemies = enemy_queue.size()
	print("Wave %d: %d musuh" % [current_wave + 1, enemy_queue.size()])
	timer.wait_time = spawn_delay
	timer.start()

func _on_timer_timeout():
	if enemy_queue.is_empty():
		timer.stop()
		current_wave += 1
		return
	var info = enemy_queue.pop_front()
	spawn_enemy(info.scene)
	timer.start()

func spawn_enemy(scene: PackedScene) -> void:
	var pf = PathFollow2D.new()
	pf.loop = false
	path.add_child(pf)
	var en = scene.instantiate()
	pf.add_child(en)
	en.path_follow = pf
	en.connect("enemy_died", Callable(self, "_on_enemy_died"))

func _on_enemy_died() -> void:
	remaining_enemies -= 1
	print("sisa musuh:", remaining_enemies)
	if remaining_enemies == 0:
		print("Wave %d selesai!" % (current_wave))	
		if current_wave != wave_data.size():
			start_battle.visible = true	
		else:
			start_wave()
