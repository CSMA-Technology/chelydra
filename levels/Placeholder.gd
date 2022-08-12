extends Node2D

var GridOverlay = preload("res://levels/GridOverlay.tscn")

var isGridOff = true

func _on_Button_pressed():
	var grid = $GridOverlay
	isGridOff = !isGridOff
	if(isGridOff):
		grid.queue_free()
	else:
		grid = GridOverlay.instance()
		add_child(grid)
	
