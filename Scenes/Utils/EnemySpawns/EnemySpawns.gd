extends TileMap

export var spawn_interval = 5
export var plus_minus = 1
export var is_spawning = false setget handle_is_spawning

var spawn_positions = []

func _ready():
	for cell in get_used_cells():
		spawn_positions.append(to_global(map_to_world(cell)))

signal spawn_enemy(position, enemy)

func handle_is_spawning(val):
	is_spawning = val
	if is_spawning:
		spawn()
	maybe_start_timer()

func maybe_start_timer():
	if is_spawning:
		$SpawnTimer.start(spawn_interval + ((randf() * plus_minus) - plus_minus))

func _on_SpawnTimer_timeout():
	if is_spawning:
		spawn()
	maybe_start_timer()

func spawn():
	var cells = get_used_cells()
	var random_cell = cells[randi() % cells.size()]
	var center_point = (random_cell * cell_size) + Vector2(cell_size.x/2, cell_size.y/2)
	emit_signal("spawn_enemy", center_point, load(choose_enemy()))

func choose_enemy():
	var choice = GameManager.EnemyEnum.keys()[randi() % GameManager.EnemyEnum.size()]
	return GameManager.get_enemy(choice)
