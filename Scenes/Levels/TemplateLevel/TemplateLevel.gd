extends Node2D

onready var score_label = $ScoreLabel
onready var tower_options = $HUD/Debug/TowerOptionButton
var TowerPlacement = preload("res://Scenes/Utils/TowerPlacement/TowerPlacement.tscn")
var is_grid_on = false
var tower_selection
export var placement_mode = false
export var health = 3

const TOWER_SIZE = Vector2(64, 64)

func _ready():
	randomize()
	update_score_label(health)
	# debug for the option menu
	for key in GameManager.TowerEnum.keys():
		tower_options.add_item(key)
	tower_options.selected = 0
	tower_selection = tower_options.get_item_text(tower_options.selected)
#	$EnemySpawns.is_spawning = true

func _physics_process(delta):
	var spawn_point = $EnemySpawns.spawn_positions[3]
	Navigation2DServer.map_force_update($MockNavigation.map)
#	$Line2D.points = Navigation2DServer.map_get_path($MockNavigation.map, spawn_point, $Goal.global_position, false, $MockNavigation.navigation_layers)
#	$Line2D2.points = Navigation2DServer.map_get_path(get_world_2d().get_navigation_map(), spawn_point, $Goal.global_position, false)

func _process(delta):
	if (placement_mode):
		$TowerPlacement.show()
		tower_options.disabled = false
	else:
		$TowerPlacement.hide()
		tower_options.disabled = true

# debug / dev function
func _on_PlacementModeButton_toggled(placement_mode_toggle):
	placement_mode = placement_mode_toggle

func place_tower(position, tower):
	var tower_scene = GameManager.get_tower_scene(tower_selection)
	var tower_type = load(tower_scene)
	var new_tower = tower_type.instance()
	new_tower.position = position
	$Towers.add_child(new_tower)
	$Navigation.cut_hole(new_tower.global_position, true, true)
#	$MockNavigation.cut_hole(new_tower.global_position, true, true)
	print("Placed at ", position)
	var neighbors = [
		position + -TOWER_SIZE,
		position + Vector2(0, -TOWER_SIZE.y),
		position + Vector2(TOWER_SIZE.x, -TOWER_SIZE.y),
		position + Vector2(-TOWER_SIZE.x, 0),
		position + Vector2(TOWER_SIZE.x, 0),
		position + Vector2(-TOWER_SIZE.x, TOWER_SIZE.y),
		position + Vector2(0, TOWER_SIZE.y),
		position + TOWER_SIZE
	]
#	for neighbor in neighbors:
#		yield(get_tree(),"idle_frame")
#		compute_tower_placement_safety(neighbor)

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
	var maybe_coroutine = $MockNavigation.clone_tilemap_locations($Navigation, placement)
	if maybe_coroutine:
		yield(maybe_coroutine, "completed")
	
#	$MockNavigation.cut_hole(placement, true)
#	$Pathfinder.global_position = spawn_point
#	$Pathfinder/NavigationAgent2D.set_target_location($Goal.global_position)
#	$Pathfinder/NavigationAgent2D.set_navigation_map($MockNavigation.map)
	yield(get_tree(), "physics_frame")
	# Assuming a contiguous spawn, then if any one position is navigable, they all are
	var spawn_point = $EnemySpawns.spawn_positions[3]
	var spawn_path = Navigation2DServer.map_get_path($MockNavigation.map, spawn_point, $Goal.global_position, false, $MockNavigation.navigation_layers)
	$Line2D.points = spawn_path
#	print($Pathfinder/NavigationAgent2D.is_target_reachable())
	if !spawn_path || spawn_path[spawn_path.size()-1] != $Goal.global_position:
		$TowerPlacement.set_paths_clear(placement, false, false)
		return
#	for enemy in $Enemies.get_children():
#		var enemy_path = Navigation2DServer.map_get_path($MockNavigation.map, enemy.global_position, $Goal.global_position, false, $MockNavigation.navigation_layers)
#		if !spawn_path || spawn_path[spawn_path.size()-1] != $Goal.global_position:
#			$TowerPlacement.set_paths_clear(placement, false)
#			return
	$TowerPlacement.set_paths_clear(placement, true)

func _on_TowerPlacement_check_tower_position(placement: Vector2):
	compute_tower_placement_safety(placement)
