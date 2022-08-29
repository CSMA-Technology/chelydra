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
var known_good_placements = []

func _physics_process(delta):
	if not visible: return
	if has_snap_changed:
		has_snap_changed = false
		debounce_tower_position_check()
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
				place_tower(event.position)

func calculate_snap_position(actual_position):
	return Vector2(clamp(int(actual_position.x/cell_size), 0, 23), clamp(int(actual_position.y/cell_size), 0, 11))

func is_placement_valid():
	return (
		!known_bad_placements.has(tower.global_position) &&
		(are_all_paths_clear || !has_neighbors() || known_good_placements.has(tower.global_position)) &&
		!is_overlapping_something()
		)

func is_overlapping_something():
	return tower.get_overlapping_areas().size() > 0 || tower.get_overlapping_bodies().size() > 0

func has_neighbors():
	return $TowerPlaceholder/NeighborChecker.get_overlapping_bodies().size() > 0

func place_tower(position):
	known_good_placements.clear()
	emit_signal("place_tower", calculate_snap_position(position)*cell_size, tower_scene)

func set_paths_clear(placement: Vector2, are_paths_clear: bool, memoize=false):
	if placement == tower.position:
		are_all_paths_clear = are_paths_clear
	if memoize:
		if are_paths_clear:
			known_good_placements.append(placement)
		else:
			known_bad_placements.append(placement)

func check_tower_position():
	# Wait one physics frame so that the collision on the neighbor check updates
	yield(get_tree(), "physics_frame")
	if (
		has_neighbors() 
		&& !is_overlapping_something()
		&& !known_bad_placements.has(tower.position) 
		&& !known_good_placements.has(tower.position)
		):
			emit_signal("check_tower_position", tower.position)

func debounce_tower_position_check():
	# Doing it in this order is important since we are waiting a frame below, if we start the timer after the yield it is possible two calls will stack up
	var was_stopped = $DebounceTimer.is_stopped()
	$DebounceTimer.start()
	if was_stopped:
		check_tower_position()
	

func _on_DebounceTimer_timeout():
	check_tower_position()
