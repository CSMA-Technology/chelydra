extends TileMap

# Mostly copied from https://escada-games.itch.io/randungeon/devlog/261991/how-to-use-godots-astar2d-for-path-finding

var aStar:AStar2D
export var debug_mode = false setget set_debug_mode
export (NodePath) var goal
onready var goal_pos = get_node(goal).global_position
const GOAL_IDX = 69420

var target_texture = preload("res://Assets/GFX/pointers/crosshair063.png")

func _ready():
	aStar = AStar2D.new()
	for cell in get_used_cells():
		var idx = get_AStar_cell_id(cell)
		var point = get_cell_point(cell)
		aStar.add_point(idx, point)
	for cell in get_used_cells():
		for neighbor in get_neighboring_cells(cell):
			aStar.connect_points(get_AStar_cell_id(cell), get_AStar_cell_id(neighbor))
	aStar.add_point(GOAL_IDX, goal_pos)
	aStar.connect_points(GOAL_IDX, get_AStar_cell_id(world_to_map(goal_pos)))
	if debug_mode:
		draw_debug_points()

func get_path_to_goal(from: Vector2):
	return aStar.get_point_path(get_AStar_cell_id(get_cell_from_pos(from)), GOAL_IDX)

func get_AStar_cell_id(cellv: Vector2):
	return int(cellv.y + cellv.x * get_used_rect().size.y)

func get_cell_point(cellv: Vector2):
	return map_to_world(cellv) + cell_size/2

func get_cell_from_pos(pos: Vector2):
	return Vector2(floor(pos.x/cell_size.x), floor(pos.y/cell_size.y))

func disconnect_cell_from_pos(pos: Vector2):
	var cell = get_cell_from_pos(pos)
	var idx = get_AStar_cell_id(cell)
	var disconnected_cells = []
	for neighbor in get_neighboring_cells(cell):
		var neighbor_idx = get_AStar_cell_id(neighbor)
		if aStar.are_points_connected(idx, neighbor_idx):
			aStar.disconnect_points(idx, neighbor_idx)
			disconnected_cells.append([idx, neighbor_idx])
	return disconnected_cells

func restore_cell_connections(cell_pairs):
	for cell_pair in cell_pairs:
		aStar.connect_points(cell_pair[0], cell_pair[1])

func connect_cell_from_pos(pos: Vector2):
	var cell = get_cell_from_pos(pos)
	var idx = get_AStar_cell_id(cell)
	for neighbor in get_neighboring_cells(cell):
		aStar.connect_points(idx, get_AStar_cell_id(neighbor))

func is_goal_reachable(from: Vector2):
	var path = get_path_to_goal(from)
	return !!path

func get_neighboring_cells(cellv: Vector2):
	# TODO: Add support for diagonal connections.
	# It mostly works fine if we include them,
	# but we just need to make sure to disconnect points that were connected diagonally when placing towers diagonally
	var neighbors = [
#		cellv + Vector2(-1, -1), # Upper-left
		cellv + Vector2(0, -1), # Straight above
#		cellv + Vector2(1, -1), # Upper-right
		cellv + Vector2(-1, 0), # Left
		cellv + Vector2(1, 0), # Right
#		cellv + Vector2(-1, 1), # Lower-left
		cellv + Vector2(0, 1), # Straight below
#		cellv + Vector2(1, 1), # Lower-right
		]
	var filtered_neighbors = []
	for neighbor in neighbors:
		if get_cellv(neighbor) != INVALID_CELL:
			filtered_neighbors.append(neighbor)
	return filtered_neighbors

func draw_debug_points():
	if $Debug.get_child_count() > 0:
		clear_debug_points()
	for cell in get_used_cells():
		var point = get_cell_point(cell)
		var idx = get_AStar_cell_id(cell)
		var sprite = Sprite.new()
		sprite.texture = target_texture
		sprite.scale = Vector2(0.25, 0.25)
		sprite.global_position = point
		$Debug.add_child(sprite)
		for neighbor in get_neighboring_cells(cell):
			if aStar.are_points_connected(idx, get_AStar_cell_id(neighbor)):
				var debug_line = Line2D.new()
				debug_line.points = PoolVector2Array([get_cell_point(cell), get_cell_point(neighbor)])
				debug_line.width = 2
				$Debug.add_child(debug_line)
	var goal_sprite = Sprite.new()
	goal_sprite.texture = target_texture
	goal_sprite.position = goal_pos
	goal_sprite.scale = Vector2(0.25, 0.25)
	goal_sprite.modulate = Color.red
	$Debug.add_child(goal_sprite)
	var debug_line = Line2D.new()
	debug_line.points = PoolVector2Array([goal_pos, get_cell_point(world_to_map(goal_pos))])
	debug_line.width = 2
	debug_line.default_color = Color.red
	$Debug.add_child(debug_line)

func clear_debug_points():
	for child in $Debug.get_children():
		$Debug.remove_child(child)

func set_debug_mode(val):
	debug_mode = val
	if aStar:
		if debug_mode:
			draw_debug_points()
		else:
			clear_debug_points()
