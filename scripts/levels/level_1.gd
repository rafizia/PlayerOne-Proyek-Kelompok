extends Node2D

@onready var path := $Path2D
@onready var timer := $Timer
@onready var hp_label := $Level_UI/Health/HPLabel
@onready var wave_label := $Level_UI/Waves/WaveLabel

@export var spawn_delay := 1.0
var hp := 15
var current_wave := 0
var remaining_enemies := 0
var enemy_queue := []

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
	
	# DO NOT start waves automatically
	# The start_wave will be called by the start_battle button

func get_bgm():
	return bgm

func start_wave():
	enemy_queue.clear()
	if current_wave == 0:
		SoundManager.play_bgm(runbgm,true)
	if current_wave >= wave_data.size():
		SoundManager.play_bgm(winbgm, false, false)
		print("Semua wave selesai!")
		return
	# queue wave
	enemy_queue = wave_data[current_wave].duplicate()
	wave_label.text = "Wave %d/%d" % [current_wave + 1, wave_data.size()]
	print("Wave %d: %d musuh" % [current_wave + 1, enemy_queue.size()])
	timer.wait_time = spawn_delay
	timer.start()

func _on_timer_timeout():
	if enemy_queue.is_empty():
		timer.stop()
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
	remaining_enemies += 1

func _on_enemy_died() -> void:
	decrease_hp()
	remaining_enemies -= 1
	if remaining_enemies == 0 and enemy_queue.is_empty():
		print("Wave %d completed!" % (current_wave + 1))
		await get_tree().create_timer(2.0).timeout
		current_wave += 1
		start_wave()

func decrease_hp() -> void:
	hp -= 1
	hp_label.text = "%d" % hp
	if hp <= 0:
		game_over()

func game_over() -> void:
	SoundManager.play_bgm(losebgm, false, false)
	print("Game Over!")
