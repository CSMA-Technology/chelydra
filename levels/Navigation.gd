extends TileMap

const TOWER_SIZE = 64
const BUFFER = 1
func _ready():
	update_nav_area()

func update_nav_area():
	for tower in $"../Towers".get_children():
		var starting_cell_v = tower.global_position/cell_size
		for offset_x in range(-BUFFER, TOWER_SIZE/cell_size.x + BUFFER):
			for offset_y in range(-BUFFER, TOWER_SIZE/cell_size.y + BUFFER):
				var offset_v = Vector2(offset_x, offset_y)
				set_cellv(starting_cell_v + offset_v, -1)
	update_dirty_quadrants()
	get_tree().call_group("Navigators", "update_path")
