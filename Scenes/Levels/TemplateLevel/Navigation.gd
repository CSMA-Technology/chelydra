extends TileMap

const TOWER_SIZE = 64
const BUFFER = 1

func _ready():
	update_nav_area()

func update_nav_area():
	for tower in $"../Towers".get_children():
		cut_hole(tower.global_position)
	update_navigation(true)

func cut_hole(position: Vector2, update=false, publish=false):
	edit_tile(position, -1)
	if update:
		update_navigation(publish)

func fill_hole(position: Vector2, update=false, publish=false):
	edit_tile(position, 0)
	update_nav_area()
	if update:
		update_navigation(publish)


func edit_tile(position: Vector2, tile_idx: int):
	var starting_cell_v = position/cell_size
	for offset_x in range(-BUFFER, TOWER_SIZE/cell_size.x + BUFFER):
		for offset_y in range(-BUFFER, TOWER_SIZE/cell_size.y + BUFFER):
			var offset_v = Vector2(offset_x, offset_y)
			set_cellv(starting_cell_v + offset_v, tile_idx)

func update_navigation(publish=false):
	update_dirty_quadrants()
	Navigation2DServer.map_force_update(get_world_2d().get_navigation_map())
	if publish:
		get_tree().call_group("Navigators", "update_path")
