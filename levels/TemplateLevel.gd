extends Node2D

var TowerPlacement = preload("res://levels/TowerPlacement.tscn")
var enemy = preload("res://Enemies/TemplateEnemy.tscn")
var is_grid_on = false
export var placement_mode = false

func _process(_delta):
	if (placement_mode):
		$TowerPlacement.show()
	else:
		$TowerPlacement.hide()

func _on_PlacementModeButton_toggled(placement_mode_toggle):
	placement_mode = placement_mode_toggle

func place_tower(position, tower):
	var new_tower = tower.instance()
	new_tower.position = position
	$Towers.add_child(new_tower)
	$Navigation.update_nav_area()


func spawn_enemy(position):
	var new_enemy = enemy.instance()
	new_enemy.position = position
	new_enemy.debug_mode = true
	$Enemies.add_child(new_enemy)
