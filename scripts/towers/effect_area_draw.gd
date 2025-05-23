extends CollisionShape2D


func _ready():
	hide()
	

func _draw():
	var cen = Vector2(0,0)
	var rad =  get_parent().get_parent().current_range_radius
	var col = Color(0.2, 0.2, 0.2, 0.5)
	draw_circle(cen, rad, col)
