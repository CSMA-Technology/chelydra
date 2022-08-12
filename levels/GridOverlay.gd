extends Node2D

onready var grid_size = Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y)
var cell_size = 64
var coord = Vector2.ZERO

func _input(event):
	if event is InputEventMouseMotion:
		var position = Vector2(int(event.position.x/cell_size), int(event.position.y/cell_size))
		if position != coord:
			coord = position
			print("Mouse at : ", coord)
