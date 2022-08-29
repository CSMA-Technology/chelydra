extends "res://Scenes/Levels/TemplateLevel/Navigation.gd"

var map:RID

func _ready():
	map = Navigation2DServer.map_create()
	Navigation2DServer.map_set_edge_connection_margin(map, Navigation2DServer.map_get_edge_connection_margin(get_world_2d().get_navigation_map()))
	Navigation2DServer.map_set_cell_size(map, Navigation2DServer.map_get_cell_size(get_world_2d().get_navigation_map()))
	Navigation2DServer.map_set_active(map, true)
	yield(get_tree(),"physics_frame")
	clone_tilemap_locations($"../Navigation")

func edit_tile(position: Vector2, tile_idx: int):
	var edited_cells = .edit_tile(position, tile_idx)
	yield(get_tree(), "physics_frame")
	claim_regions()
	yield(get_tree(), "physics_frame")
	return edited_cells

func restore_cells(cells):
	for cell in cells:
		set_cellv(cell, 0)
	yield(get_tree(), "physics_frame")
	claim_regions()

func update_navigation():
	update_dirty_quadrants()
	Navigation2DServer.map_force_update(map)

func clone_tilemap_locations(source: TileMap):
	assert(source.cell_size == cell_size, "Error: Cannot clone a tilemap with a different cell_size")
	if source.get_used_cells().hash() == get_used_cells().hash():
		return
	clear()
	for cell in source.get_used_cells():
		set_cellv(cell, 0)
	yield(get_tree(), "physics_frame")
	claim_regions()

func claim_regions():
	for region in Navigation2DServer.map_get_regions(get_world_2d().get_navigation_map()):
		if Navigation2DServer.region_get_navigation_layers(region) == navigation_layers:
			if Navigation2DServer.region_get_map(region) != map:
				Navigation2DServer.region_set_map(region, map)
