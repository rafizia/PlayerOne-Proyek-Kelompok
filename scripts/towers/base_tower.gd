extends Node2D
class_name BaseTower

# Tower properties
var tower_name: String = "Base Tower"
var tower_level: int = 1
var max_level: int = 3
var build_cost: int = 0
var maintenance_cost: int = 0
var is_active: bool = true

# Upgrade panel
@onready var upgrade_panel = $Upgrade
@onready var cost_label = $Upgrade/MarginContainer/VBoxContainer/Cost
@onready var click_area = $ClickArea
@onready var effect_area_collision = $EffectArea/CollisionShape2D

# Called when the node enters the scene tree for the first time
func _ready():
	add_to_group("towers")
	
	# Hide upgrade panel initially
	if upgrade_panel:
		upgrade_panel.hide()
		upgrade_panel.z_index = 100
		
	# Connect to resource manager for cost updates
	if ResourcesManager._instance:
		ResourcesManager._instance.connect("resources_updated", Callable(self, "_on_resources_updated"))

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if upgrade_panel and upgrade_panel.visible:
			# Check if click is outside both the tower and upgrade panel
			var click_pos = get_global_mouse_position()
			if !click_area.get_global_rect().has_point(click_pos) and !upgrade_panel.get_global_rect().has_point(click_pos):
				upgrade_panel.hide()
				if effect_area_collision:
					effect_area_collision.hide()

func _on_click_area_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toggle_upgrade_panel()

func _on_upgrade_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if upgrade():
			upgrade_panel.hide()
			if effect_area_collision:
				effect_area_collision.hide()

func toggle_upgrade_panel():
	if !upgrade_panel:
		return
		
	if upgrade_panel.visible:
		upgrade_panel.hide()
		if effect_area_collision:
			effect_area_collision.hide()
	else:
		position_upgrade_panel()
		update_upgrade_cost()
		upgrade_panel.show()
		if effect_area_collision:
			effect_area_collision.show()

func position_upgrade_panel():
	if !upgrade_panel:
		return
		
	# Get viewport size
	var viewport_size = get_viewport_rect().size
	
	# Calculate distance from right edge
	var distance_from_right = viewport_size.x - global_position.x
	
	# If tower is closer to right edge, show panel on left
	if distance_from_right < 150:  # 150 is an example threshold
		upgrade_panel.position.x = -upgrade_panel.size.x - 30
	else:
		upgrade_panel.position.x = 30

func update_upgrade_cost():
	if !cost_label:
		return
		
	var cost = get_upgrade_cost()
	if cost > 0:
		cost_label.text = str(cost)
		# Make label darker if can't afford
		if ResourcesManager._instance and ResourcesManager._instance.gold < cost:
			cost_label.modulate = Color(0.7, 0.7, 0.7)
		else:
			cost_label.modulate = Color(1, 1, 1)
	else:
		cost_label.text = "MAX"

func _on_resources_updated(energy, gold, hp):
	if upgrade_panel and upgrade_panel.visible:
		update_upgrade_cost()

# Tower activation/deactivation
func set_active(active: bool):
	is_active = active

# To be overridden by child classes
func update_tower_stats():
	pass

# To be overridden by child classes
func get_upgrade_cost() -> int:
	return 0

# Upgrade tower if possible
func upgrade() -> bool:
	if tower_level < max_level:
		var cost = get_upgrade_cost()
		if ResourcesManager._instance and ResourcesManager._instance.gold >= cost:
			ResourcesManager._instance.gold -= cost
			# Emit resources updated signal to update UI
			if ResourcesManager._instance.has_signal("resources_updated"):
				ResourcesManager._instance.emit_signal("resources_updated", 
					ResourcesManager._instance.energy,
					ResourcesManager._instance.gold,
					ResourcesManager._instance.hp
				)
			
			tower_level += 1
			if tower_level == 2:
				if has_node("AnimatedSprite2D"):
					$AnimatedSprite2D.modulate = Color.YELLOW
				else:
					$Base.modulate = Color.YELLOW
					$Muzzle.modulate = Color.YELLOW			
			elif tower_level == 3:
				if has_node("AnimatedSprite2D"):
					$AnimatedSprite2D.modulate = Color.RED
				else:
					$Base.modulate = Color.RED
					$Muzzle.modulate = Color.RED
			update_tower_stats()
			update_upgrade_cost()
			return true
	return false
