extends "res://Scenes/Levels/TemplateLevel/Navigation.gd"

var map:RID

func _ready():
	map = Navigation2DServer.map_create()
	Navigation2DServer.map_set_edge_connection_margin(map, Navigation2DServer.map_get_edge_connection_margin(get_world_2d().get_navigation_map()))
	Navigation2DServer.map_set_cell_size(map, Navigation2DServer.map_get_cell_size(get_world_2d().get_navigation_map()))
	Navigation2DServer.map_set_active(map, true)
	yield(get_tree(),"physics_frame")
	clone_tilemap_locations($"../Navigation")

func _physics_process(delta):
	claim_regions()

func edit_tile(position: Vector2, tile_idx: int):
	var edited_cells = .edit_tile(position, tile_idx)
	yield(get_tree(), "physics_frame")
	claim_regions()
	return edited_cells

func restore_cells(cells):
	for cell in cells:
		set_cellv(cell, 0)

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

var last_hash = [].hash()
func claim_regions():
	var regions = Navigation2DServer.map_get_regions(get_world_2d().get_navigation_map())
	if last_hash == regions.hash():
		return
	last_hash = regions.hash()
	for region in regions:
		if Navigation2DServer.region_get_navigation_layers(region) == navigation_layers:
			if Navigation2DServer.region_get_map(region) != map:
				Navigation2DServer.region_set_map(region, map)
