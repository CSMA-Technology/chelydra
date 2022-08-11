extends Node2D

var GridOverlay = preload("res://levels/GridOverlay.tscn")

var isGridOff = true

func _on_Button_pressed():
	if(!isGridOff):
		var grid = GridOverlay.instance()
		add_child(grid)
