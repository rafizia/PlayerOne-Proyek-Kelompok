extends CanvasLayer

@export var bgm : AudioStreamMP3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.play_bgm(bgm)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
