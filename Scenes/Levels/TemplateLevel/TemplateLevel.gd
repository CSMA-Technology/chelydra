extends Node2D

onready var score_label = $ScoreLabel
onready var tower_options = $HUD/Debug/TowerOptionButton
var TowerPlacement = preload("res://Scenes/Utils/TowerPlacement/TowerPlacement.tscn")
var is_grid_on = false
var tower_selection
export var placement_mode = false
export var health = 3

const TOWER_SIZE = Vector2(64, 64)

var current_spawn_path

func _ready():
	randomize()
	update_score_label(health)
	# debug for the option menu
	for key in GameManager.TowerEnum.keys():
		tower_options.add_item(key)
	tower_options.selected = 0
	tower_selection = tower_options.get_item_text(tower_options.selected)
	$EnemySpawns.is_spawning = true
	Navigation2DServer.connect("map_changed", self, "update_spawn_path")

func _process(delta):
	if (placement_mode):
		$TowerPlacement.show()
		tower_options.disabled = false
	else:
		$TowerPlacement.hide()
		tower_options.disabled = true

func update_spawn_path(map):
	if map == get_world_2d().get_navigation_map():
		current_spawn_path = Navigation2DServer.map_get_path(get_world_2d().get_navigation_map(), $EnemySpawns.spawn_positions[0], $Goal.global_position, false)
		$Line2D.points = current_spawn_path

# debug / dev function
func _on_PlacementModeButton_toggled(placement_mode_toggle):
	placement_mode = placement_mode_toggle

func place_tower(position, tower):
	var tower_scene = GameManager.get_tower_scene(tower_selection)
	var tower_type = load(tower_scene)
	var new_tower = tower_type.instance()
	new_tower.position = position
	$Towers.add_child(new_tower)
	$Navigation.cut_hole(new_tower.global_position, true)
	$MockNavigation.cut_hole(new_tower.global_position)

func spawn_enemy(position, enemy):
	var new_enemy = enemy.instance()
	new_enemy.position = position
	$Enemies.add_child(new_enemy)
	if new_enemy.has_signal("reached_goal"):
		new_enemy.connect("reached_goal", self, "_on_Enemy_reached_goal")

func update_score_label(score):
	score_label.text = "HP: " + str(score)

func _on_Enemy_reached_goal(damage):
	health -= damage
	update_score_label(health)
	if (health <= 0):
		get_tree().quit()

# debug / dev function
func _on_SpawnEnemyButton_pressed():
	$EnemySpawns.spawn()

func _on_TowerOptionButton_item_selected(index):
	tower_selection = tower_options.get_item_text(index)

func compute_tower_placement_safety(placement: Vector2):
	var tower_polygon = PoolVector2Array([placement, placement + Vector2(64, 0), placement + Vector2(0, 64), placement + Vector2(64, 64)])
	var spawn_path_clear = !Geometry.intersect_polyline_with_polygon_2d(current_spawn_path, tower_polygon)
	var enemies_obstructed = []
	for enemy in $Enemies.get_children():
		if Geometry.intersect_polyline_with_polygon_2d(enemy.path, tower_polygon):
			enemies_obstructed.append(enemy.global_position)
	if spawn_path_clear && !enemies_obstructed:
		$TowerPlacement.set_paths_clear(placement, true, true)
		return
	
	var edited_cells = $MockNavigation.cut_hole(placement)
	if edited_cells is GDScriptFunctionState:
		edited_cells = yield(edited_cells, "completed")

	if !spawn_path_clear:
		# Assuming a contiguous spawn, then if any one position is navigable, they all are
		var spawn_point = $EnemySpawns.spawn_positions[0]
		yield(get_tree(), "idle_frame")
		var spawn_path = Navigation2DServer.map_get_path($MockNavigation.map, spawn_point, $Goal.global_position, false, $MockNavigation.navigation_layers)
		if !spawn_path || spawn_path[spawn_path.size()-1] != $Goal.global_position:
			$TowerPlacement.set_paths_clear(placement, false, true)
			$MockNavigation.restore_cells(edited_cells)
			return
	
	for enemy_pos in enemies_obstructed:
		yield(get_tree(), "idle_frame")
		var enemy_path = Navigation2DServer.map_get_path($MockNavigation.map, enemy_pos, $Goal.global_position, false, $MockNavigation.navigation_layers)
		if !enemy_path || enemy_path[enemy_path.size()-1] != $Goal.global_position:
			$TowerPlacement.set_paths_clear(placement, false, false)
			$MockNavigation.restore_cells(edited_cells)
			return
	
	$TowerPlacement.set_paths_clear(placement, true, true)
	$MockNavigation.restore_cells(edited_cells)


func _on_TowerPlacement_check_tower_position(placement: Vector2):
	compute_tower_placement_safety(placement)

