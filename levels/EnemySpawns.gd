extends TileMap

export var spawn_interval = 5
export var plus_minus = 1
export var is_spawning = true setget handle_is_spawning

signal spawn_enemy(position)

func _ready():
	if is_spawning:
		spawn()
	maybe_start_timer()

func handle_is_spawning(val):
	is_spawning = val
	maybe_start_timer()

func maybe_start_timer():
	if is_spawning:
		$SpawnTimer.start(spawn_interval + ((randf() * plus_minus) - plus_minus))

func _on_SpawnTimer_timeout():
	spawn()
	maybe_start_timer()

func spawn():
	if is_spawning:
		var cells = get_used_cells()
		var random_cell = cells[randi() % cells.size()]
		var center_point = (random_cell * cell_size) + Vector2(cell_size.x/2, cell_size.y/2)
		emit_signal("spawn_enemy", center_point)
