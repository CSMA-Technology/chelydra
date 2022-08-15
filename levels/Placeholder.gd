extends Node2D

var GridOverlay = preload("res://levels/GridOverlay.tscn")
var TowerPlacement = preload("res://levels/TowerPlacement.tscn")
var is_grid_on = false
onready var placement_mode_button = $UIPlaceholder/Control/PlacementModeButton

func _on_ToggleGridButton_toggled(grid_on):
	var grid_nodes = get_tree().get_nodes_in_group("grid")
	if(grid_on):
		is_grid_on = true
		placement_mode_button.disabled = false
		var new_grid = GridOverlay.instance()
		add_child(new_grid)
	else:
		is_grid_on = true
		placement_mode_button.disabled = true
		for i in grid_nodes.size():
			grid_nodes[i].queue_free()


func _on_PlacementModeButton_toggled(placement_mode_on):
	if(placement_mode_on):
		var new_tower = TowerPlacement.instance()
		add_child(new_tower)
