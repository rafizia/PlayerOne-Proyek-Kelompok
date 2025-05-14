extends CharacterBody2D
## Flyer type of enemy
##
## Technically, this is your regular enemy with their special path2D, either the map have one unique
## flyer path, or we can make many unique flyer path to make wave varieties.
##
## currently one instance of enemy got their own path instantiated by PathSpawner on a timer
##
## should be made modular to other enemy type (make generic enemy class to be inherted to) 
## to make them uniform (13/5/25)

const SPEED = 300
@onready var animated_sprite = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	
	animated_sprite.play("idle")
	var curpos = get_parent().get_progress_ratio() #check curren path progress
	get_parent().set_progress(get_parent().get_progress() + SPEED*delta) #set path progress according to delta
	if get_parent().get_progress_ratio() < curpos: #if the progress loops back or reach finish
		queue_free()
