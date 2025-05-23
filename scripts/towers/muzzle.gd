extends AnimatedSprite2D

func _process(delta):   
	var angle_deg = rotation_degrees

	if (angle_deg < -90 and angle_deg > -270) or (angle_deg > 90 and angle_deg < 270):
		flip_v = true
	else:
		flip_v = false
