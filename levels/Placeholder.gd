extends Node2D

var GridOverlay = preload("res://levels/GridOverlay.tscn")
var TemplateTower = preload("res://Towers/TemplateTower.tscn")
var is_grid_off = true
	
func _on_ToggleGridButton_pressed():
	var grid_nodes = get_tree().get_nodes_in_group("grid")
	is_grid_off = !is_grid_off
	if(is_grid_off):
		for i in grid_nodes.size():
			grid_nodes[i].queue_free()
	else:
		var new_grid = GridOverlay.instance()
		add_child(new_grid)


func _on_PlaceTowerButton_pressed():
	if(!is_grid_off):
		var new_tower = TemplateTower.instance()
		new_tower.position = get_global_mouse_position()
		add_child(new_tower)
	else:
		print("can't place a tower with grid off")	
