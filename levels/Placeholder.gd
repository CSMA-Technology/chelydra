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
		is_grid_on = false
		placement_mode_button.disabled = true
		for i in grid_nodes.size():
			grid_nodes[i].queue_free() # is there a better way to do this?

func place_tower(position, tower):
	print("place a tower here: ", position)
	print(tower)
	var new_tower = tower.instance()
	new_tower.position = position
	add_child(new_tower)

func _on_PlacementModeButton_toggled(placement_mode_on):
	var placement_nodes = get_tree().get_nodes_in_group("tower_placement")
	if(placement_mode_on):
		var tower_placement = TowerPlacement.instance()
		add_child(tower_placement)
		if tower_placement.has_signal("place_tower"):
			tower_placement.connect("place_tower", self, "place_tower")
	else:
		for i in placement_nodes.size():
			placement_nodes[i].queue_free()
