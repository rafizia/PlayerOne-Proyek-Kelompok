extends Node2D
## Node to manage sound playing through the game
##
## already been set to be a global node, so you can put the node.function directly on the code
## put `SoundManager.play_sfx(AudioStream)` to play sfx, `SoundManager.play_bgm(AudioStreamMP3) to set BGM.
## sfx is one and done, and can be set to change pitch each initiation with the random flag.
## bgm is a set and it loops until it's set to none or null.
## 
##

@onready var sfx_player : AudioStreamPlayer
@onready var bgm_player : AudioStreamPlayer
var bgmplaytime : float
@export var clicksfx : AudioStream

func play_sfx(sfx: AudioStream, random = false):
	if sfx:
		sfx_player = AudioStreamPlayer.new()
		add_child(sfx_player)
		sfx_player.set_process_mode(1)
		
		sfx_player.stream = sfx
		sfx_player.bus = "SFX"
		
		if random:
			sfx_player.set_pitch_scale(randf_range(0.75,2))
		sfx_player.play()
		
		sfx_player.finished.connect(sfx_player.queue_free)
		
func play_bgm(bgm: AudioStreamMP3, switch = false, loop = true):
	if bgm:
		bgm.loop = loop
		if !bgm_player:
			bgm_player = AudioStreamPlayer.new()
			add_child(bgm_player)
			bgm_player.set_process_mode(3)
		if switch:
			bgmplaytime = bgm_player.get_playback_position()
		else:
			bgmplaytime = 0
		bgm_player.stream = bgm
		bgm_player.bus = "BGM"
		bgm_player.play(bgmplaytime)

func stop_bgm():
	bgm_player.stop()
	
func play_click():
	play_sfx(clicksfx)
