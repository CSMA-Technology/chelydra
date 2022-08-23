extends Node2D

onready var score_label = $ScoreLabel
onready var tower_options = $HUD/Debug/TowerOptionButton
var TowerPlacement = preload("res://Scenes/Utils/TowerPlacement/TowerPlacement.tscn")
var is_grid_on = false
var tower_selection
export var placement_mode = false
export var health = 3

func _ready(): 
	randomize()
	update_score_label(health)
	# debug for the option menu 
	for key in GameManager.TowerEnum.keys():
		tower_options.add_item(key) 
	tower_options.selected = 0
	tower_selection = tower_options.get_item_text(tower_options.selected)
	$EnemySpawns.is_spawning = true

func _process(_delta):
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
	$Navigation.update_nav_area()

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
