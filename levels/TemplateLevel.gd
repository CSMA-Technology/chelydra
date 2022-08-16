extends Node2D

var TowerPlacement = preload("res://levels/TowerPlacement.tscn")
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
	add_child(new_tower)
