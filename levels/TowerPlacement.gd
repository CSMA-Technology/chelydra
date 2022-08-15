extends Node2D

onready var tower = $TemplateTower
var cell_size = 64

func _input(event):
	if event is InputEventMouseMotion:
		var snap_position = Vector2(clamp(int(event.position.x/cell_size), 0, 21), clamp(int(event.position.y/cell_size), 0, 11))
		tower.position = snap_position*64
		print("Mouse at : ", snap_position)
