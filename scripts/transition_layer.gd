extends CanvasLayer

signal on_transition_finished

@onready var fade_rect = $ColorRect
@onready var loading_label = $Label
@onready var animation_player = $AnimationPlayer
@export var is_loading: bool

func _ready():
	fade_rect.visible = false
	self.layer = 100

func transition(loading: bool):
	is_loading = loading
	fade_rect.visible = true
	animation_player.play("fade_in")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		on_transition_finished.emit()
		if (is_loading):
			SoundManager.stop_bgm()
			loading_label.visible = true
			await get_tree().create_timer(0.8).timeout
		animation_player.play("fade_out")
		loading_label.visible = false
		
		# Reinitialize tower placer manager if we're in a level scene
		var current_scene = get_tree().current_scene
		if current_scene != null and current_scene.name.begins_with("Level"):
			var tower_placer = get_node("/root/TowerPlacerManager")
			if tower_placer:
				tower_placer.initialize_level()
			SoundManager.play_bgm(current_scene.get_bgm())
	elif anim_name == "fade_out":
		fade_rect.visible = false
