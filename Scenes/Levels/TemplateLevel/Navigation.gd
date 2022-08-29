extends TileMap

const TOWER_SIZE = 64
const BUFFER = 1

func _ready():
	update_nav_area()

func update_nav_area():
	for tower in $"../Towers".get_children():
		cut_hole(tower.global_position)
	update_navigation()

func cut_hole(position: Vector2, update=false):
	var edited_cells = edit_tile(position, -1)
	if edited_cells is GDScriptFunctionState:
		edited_cells = yield(edited_cells, "completed")
	if update:
		update_navigation()
	return edited_cells

func fill_hole(position: Vector2, update=false):
	edit_tile(position, 0)
	update_nav_area()
	if update:
		update_navigation()


func edit_tile(position: Vector2, tile_idx: int):
	var edited_cells = []
	var starting_cell_v = world_to_map(position)
	var top_row = starting_cell_v.y - BUFFER
	var bottom_row = starting_cell_v.y + TOWER_SIZE/cell_size.y - 1 + BUFFER
	var left_col = starting_cell_v.x - BUFFER
	var right_col = starting_cell_v.x + TOWER_SIZE/cell_size.y - 1 + BUFFER
	
	# Just tracing an outline of the tower in order to minimize nav areas edited
	for x in range(left_col, right_col + 1):
		for y in [top_row, bottom_row]:
			var cell_position = Vector2(x, y)
			if get_cellv(cell_position) != tile_idx:
				set_cellv(cell_position, tile_idx)
				edited_cells.append(cell_position)
	for y in range(top_row+1, bottom_row):
		for x in [left_col, right_col]:
			var cell_position = Vector2(x, y)
			if get_cellv(cell_position) != tile_idx:
				set_cellv(cell_position, tile_idx)
				edited_cells.append(cell_position)
	return edited_cells

func update_navigation():
	update_dirty_quadrants()
	Navigation2DServer.map_force_update(get_world_2d().get_navigation_map())
