extends Node2D

onready var tower = $TemplateTower
var tower_scene = preload("res://Towers/TemplateTower.tscn")
var cell_size = 64

signal place_tower(position, tower)

func _input(event):
	if (visible):
		if event is InputEventMouseMotion:
			var snap_position = calculate_snap_position(event.position)
			tower.position = snap_position*cell_size
		if event is InputEventMouseButton and event.pressed:
			var placement_area = $TileMap.get_used_rect()
			print("placement area: ", placement_area.position, " to ", placement_area.end)
			print("placement point: ", event.position/cell_size)
			if (placement_area.has_point(event.position/cell_size)):
				emit_signal("place_tower", calculate_snap_position(event.position)*cell_size, tower_scene)

func calculate_snap_position(actual_position):
	return Vector2(clamp(int(actual_position.x/cell_size), 0, 23), clamp(int(actual_position.y/cell_size), 0, 11))
