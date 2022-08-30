extends Node2D

onready var score_label = $ScoreLabel
onready var tower_options = $HUD/Debug/TowerOptionButton
var TowerPlacement = preload("res://Scenes/Utils/TowerPlacement/TowerPlacement.tscn")
var is_grid_on = false
var tower_selection
export var placement_mode = false
export var health = 3
export var is_initially_spawning = true

const TOWER_SIZE = Vector2(64, 64)

var current_spawn_paths = [null, null]

func _ready():
	randomize()
	update_score_label(health)
	# debug for the option menu
	for key in GameManager.TowerEnum.keys():
		tower_options.add_item(key)
	tower_options.selected = 0
	tower_selection = tower_options.get_item_text(tower_options.selected)
	$EnemySpawns.is_spawning = is_initially_spawning

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
	var start = Time.get_ticks_msec()
	var tower_scene = GameManager.get_tower_scene(tower_selection)
	var tower_type = load(tower_scene)
	var new_tower = tower_type.instance()
	new_tower.position = position
	$Towers.add_child(new_tower)
	$Navigation.disconnect_cell_from_pos(position)
	for enemy in $Enemies.get_children():
		enemy.set_path($Navigation.get_path_to_goal(enemy.global_position), true)
	print("Placed tower in ", Time.get_ticks_msec() - start, "ms")

func spawn_enemy(position, enemy):
	var new_enemy = enemy.instance()
	new_enemy.position = position
	new_enemy.set_path($Navigation.get_path_to_goal(position))
#	new_enemy.debug_mode = true
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

func _on_TowerPlacement_check_tower_position(placement):
	var disconnected_cells = $Navigation.disconnect_cell_from_pos(placement)
	var is_reachable_from_spawn = $Navigation.is_goal_reachable($EnemySpawns.spawn_positions[0])
	var is_reachable_from_enemies = true
	for enemy in $Enemies.get_children():
		if !$Navigation.is_goal_reachable(enemy.global_position):
			is_reachable_from_enemies = false
			break
	$Navigation.restore_cell_connections(disconnected_cells)
	$TowerPlacement.set_paths_clear(placement, is_reachable_from_spawn && is_reachable_from_enemies)
