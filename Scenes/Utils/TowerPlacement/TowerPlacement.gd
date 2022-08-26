extends Node2D

onready var tower = $TowerPlaceholder
var tower_scene = preload("res://Scenes/Towers/TemplateTower.tscn")
var cell_size = 64

const GREEN = "0c9e20"
const RED = "f1270c"

var are_all_paths_clear = false
var has_snap_changed = false

signal place_tower(position, tower)
signal check_tower_position(placement)

var known_bad_placements = []

func _physics_process(delta):
	if not visible: return
	if has_snap_changed:
		has_snap_changed = false
		yield(get_tree(), "physics_frame")
		if has_neighbors() && !known_bad_placements.has(tower.position):
			emit_signal("check_tower_position", tower.position)
	if is_placement_valid():
		$TowerPlaceholder/ColorRect.color = GREEN
	else:
		$TowerPlaceholder/ColorRect.color = RED

func _input(event):
	if (visible):
		if event is InputEventMouseMotion:
			var snap_position = calculate_snap_position(event.position) * cell_size
			if tower.position != snap_position:
				# Changing tower position
				has_snap_changed = true
				are_all_paths_clear = false
				tower.position = snap_position
		if event is InputEventMouseButton and event.pressed:
			var placement_area = $TileMap.get_used_rect()
			if (placement_area.has_point(event.position/cell_size) && is_placement_valid()):
				emit_signal("place_tower", calculate_snap_position(event.position)*cell_size, tower_scene)

func calculate_snap_position(actual_position):
	return Vector2(clamp(int(actual_position.x/cell_size), 0, 23), clamp(int(actual_position.y/cell_size), 0, 11))

func has_neighbors():
	return $TowerPlaceholder/NeighborChecker.get_overlapping_bodies().size() > 0

func is_placement_valid():
	return true
	return (
		!known_bad_placements.has(tower.global_position) &&
		(are_all_paths_clear || !has_neighbors()) &&
		!is_overlapping_something()
		)

func is_overlapping_something():
	return tower.get_overlapping_areas().size() > 0 || tower.get_overlapping_bodies().size() > 0

func _on_tower_placement_blocks_spawn(placement):
	known_bad_placements.append(placement)

func set_paths_clear(placement: Vector2, are_paths_clear: bool, memoize=false):
	if placement == tower.position:
		are_all_paths_clear = are_paths_clear
	if memoize && !are_paths_clear:
		known_bad_placements.append(placement)
