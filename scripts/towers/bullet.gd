extends CharacterBody2D

var damage: float
var speed: float
var target: Node2D
var start_position: Vector2

func setup(target_node: Node2D, bullet_damage: float, bullet_speed: float, spawn_position: Vector2):
	target = target_node
	damage = bullet_damage
	speed = bullet_speed
	global_position = spawn_position
	start_position = spawn_position

func _physics_process(delta):
	if not is_instance_valid(target) or !target.is_inside_tree():
		# If target is gone, continue in last known direction
		velocity = velocity.normalized() * speed
	else:
		var target_position = target.global_position
		velocity = global_position.direction_to(target_position) * speed
		look_at(target_position)
	
	move_and_slide()
	
	# Check for collisions or distance traveled
	if check_collisions() || global_position.distance_to(start_position) > 1000:
		queue_free()

func check_collisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("enemies"):
			if collider.has_method("take_damage"):
				collider.take_damage(damage)
			queue_free()
			return true
	return false
