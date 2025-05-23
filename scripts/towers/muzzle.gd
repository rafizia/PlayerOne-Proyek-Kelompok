extends AnimatedSprite2D

func _process(delta):   
	var angle_deg = rotation_degrees

	if (fmod(angle_deg, 360.0) < -90 and fmod(angle_deg, 360.0) > -270) or (fmod(angle_deg, 360.0) > 90 and fmod(angle_deg, 360.0) < 270):
		flip_v = true
	else:
		flip_v = false
