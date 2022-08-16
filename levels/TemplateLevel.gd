extends Node2D

onready var score_label = $ScoreLabel
var TowerPlacement = preload("res://levels/TowerPlacement.tscn")
var enemy = preload("res://Enemies/TemplateEnemy.tscn")
var is_grid_on = false
export var placement_mode = false
export var health = 3

func _ready(): 
	randomize()
	update_score_label(health)

func _process(_delta):
	if (placement_mode):
		$TowerPlacement.show()
	else:
		$TowerPlacement.hide()

# debug / dev function
func _on_PlacementModeButton_toggled(placement_mode_toggle):
	placement_mode = placement_mode_toggle

func place_tower(position, tower):
	var new_tower = tower.instance()
	new_tower.position = position
	$Towers.add_child(new_tower)
	$Navigation.update_nav_area()

func spawn_enemy(position):
	var new_enemy = enemy.instance()
	new_enemy.position = position
	new_enemy.debug_mode = true
	$Enemies.add_child(new_enemy)
	if new_enemy.has_signal("reached_goal"):
		new_enemy.connect("reached_goal", self, "_on_Enemy_reached_goal")

func update_score_label(score):
	score_label.text = "HP: " + str(score)

func _on_Enemy_reached_goal(damage):
	print("enemy reached goal!")
	health -= damage
	update_score_label(health)
	if (health <= 0):
		get_tree().quit()

# debug / dev function
func _on_SpawnEnemyButton_pressed():
	spawn_enemy(Vector2(1568, clamp(randi() % 1025, 0, 1024)))
