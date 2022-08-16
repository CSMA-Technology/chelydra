extends Node2D

onready var tower = $TowerPlaceholder
var tower_scene = preload("res://Towers/TemplateTower.tscn")
var cell_size = 64

const GREEN = "0c9e20"
const RED = "f1270c"

signal place_tower(position, tower)

func _process(delta):
	if is_placement_valid():
		$TowerPlaceholder/ColorRect.color = GREEN
	else:
		$TowerPlaceholder/ColorRect.color = RED

func _input(event):
	if (visible):
		if event is InputEventMouseMotion:
			var snap_position = calculate_snap_position(event.position)
			tower.position = snap_position*cell_size
		if event is InputEventMouseButton and event.pressed:
			var placement_area = $TileMap.get_used_rect()
			print_debug("placement area: ", placement_area.position, " to ", placement_area.end)
			print_debug("placement point: ", event.position/cell_size)
			if (placement_area.has_point(event.position/cell_size) && is_placement_valid()):
				emit_signal("place_tower", calculate_snap_position(event.position)*cell_size, tower_scene)

func calculate_snap_position(actual_position):
	return Vector2(clamp(int(actual_position.x/cell_size), 0, 23), clamp(int(actual_position.y/cell_size), 0, 11))

func is_placement_valid():
	return tower.get_overlapping_areas().size() == 0 && tower.get_overlapping_bodies().size() == 0
