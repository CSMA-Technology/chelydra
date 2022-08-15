extends Node2D

onready var tower = $TemplateTower
var tower_scene = preload("res://Towers/TemplateTower.tscn")
var cell_size = 64

signal place_tower(position, tower)

func _input(event):
	if event is InputEventMouseMotion:
		var snap_position = calculate_snap_position(event.position)
		tower.position = snap_position*cell_size
#		print("Mouse at : ", snap_position)
	if event is InputEventMouseButton and event.pressed:
		emit_signal("place_tower", calculate_snap_position(event.position)*cell_size, tower_scene) # how will we pass the packed scene of different tower types?

func calculate_snap_position(actual_position):
	return Vector2(clamp(int(actual_position.x/cell_size), 0, 23), clamp(int(actual_position.y/cell_size), 0, 11))
