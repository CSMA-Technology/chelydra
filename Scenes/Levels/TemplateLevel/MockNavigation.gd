extends "res://Scenes/Levels/TemplateLevel/Navigation.gd"

var map:RID

# Override to prevent needlessly updating the map when mounted
func _ready():
	map = Navigation2DServer.map_create()
	Navigation2DServer.map_set_edge_connection_margin(map, Navigation2DServer.map_get_edge_connection_margin(get_world_2d().get_navigation_map()))
	Navigation2DServer.map_set_cell_size(map, Navigation2DServer.map_get_cell_size(get_world_2d().get_navigation_map()))
	Navigation2DServer.map_set_active(map, true)
#	yield(get_tree(),"physics_frame")
#	yield(get_tree(),"physics_frame")
#	for region in Navigation2DServer.map_get_regions(get_world_2d().get_navigation_map()):
#		if Navigation2DServer.region_get_navigation_layers(region) == 2:
#			Navigation2DServer.region_set_map(region, map)
#	yield(get_tree(),"physics_frame")

# Override to prevent needlessly making naviagtors update their paths
func update_navigation(publish=false):
	update_dirty_quadrants()
	Navigation2DServer.map_force_update(map)
	Navigation2DServer.map_force_update(get_world_2d().get_navigation_map())
	if publish:
		get_tree().call_group("Navigators", "update_path")

func clone_tilemap_locations(source: TileMap, exclude_position:Vector2):
	var start = Time.get_ticks_msec()
	assert(source.cell_size == cell_size, "Error: Cannot clone a tilemap with a different cell_size")
#	if get_used_cells().hash() == source.get_used_cells().hash():
#		print("Already the same")
#		return
	clear()
	for cell_position in source.get_used_cells():
		var world_pos = map_to_world(cell_position)
		var snapped = Vector2(int(world_pos.x) - (int(world_pos.x) % TOWER_SIZE), int(world_pos.y) - (int(world_pos.y) % TOWER_SIZE))
		if !snapped == exclude_position:
			set_cellv(cell_position, 0)
	yield(get_tree(), "physics_frame")
	for region in Navigation2DServer.map_get_regions(get_world_2d().get_navigation_map()):
		if Navigation2DServer.region_get_navigation_layers(region) == navigation_layers:
			Navigation2DServer.region_set_map(region, map)
	yield(get_tree(), "physics_frame")
	print(Navigation2DServer.map_get_regions(get_world_2d().get_navigation_map()).size())
	print(Navigation2DServer.map_get_regions(map).size())
#	update_navigation()
	print("Cloned in ", Time.get_ticks_msec() - start)
