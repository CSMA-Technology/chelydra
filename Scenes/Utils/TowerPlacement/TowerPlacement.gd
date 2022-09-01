extends Node2D

onready var tower = $TowerPlaceholder
var tower_scene = preload("res://Scenes/Towers/TemplateTower.tscn")
var cell_size = 64

const GREEN = "0c9e20"
const RED = "f1270c"

var are_all_paths_clear = false
var towers_placed = []

signal place_tower(position, tower)
signal check_tower_position(placement)

func _physics_process(delta):
	if not visible: return
	if is_placement_valid():
		$TowerPlaceholder/ColorRect.color = GREEN
	else:
		$TowerPlaceholder/ColorRect.color = RED

func _input(event):
	if (visible):
		if event is InputEventMouseMotion:
			var snap_position = calculate_snap_position(event.position) * cell_size
			if tower.position != snap_position:
				tower.position = snap_position
				if !towers_placed.has(snap_position):
					check_tower_position()
		if event is InputEventMouseButton and event.pressed:
			var placement_area = $TileMap.get_used_rect()
			if (placement_area.has_point(event.position/cell_size) && is_placement_valid()):
				place_tower(event.position)

func calculate_snap_position(actual_position):
	return Vector2(clamp(int(actual_position.x/cell_size), 0, 23), clamp(int(actual_position.y/cell_size), 0, 11))

func is_placement_valid():
	return are_all_paths_clear && !is_overlapping_something()

func is_overlapping_something():
	return tower.get_overlapping_areas().size() > 0 || tower.get_overlapping_bodies().size() > 0

func has_neighbors():
	return $TowerPlaceholder/NeighborChecker.get_overlapping_bodies().size() > 0

func place_tower(position):
	var new_position = calculate_snap_position(position)*cell_size
	emit_signal("place_tower", new_position, tower_scene)
	towers_placed.push_front(new_position)

func set_paths_clear(placement: Vector2, are_paths_clear: bool):
	if placement == tower.position:
		are_all_paths_clear = are_paths_clear

func check_tower_position():
	are_all_paths_clear = false
	emit_signal("check_tower_position", tower.position)
