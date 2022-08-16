extends Node2D

onready var score_label = $ScoreLabel
var TowerPlacement = preload("res://levels/TowerPlacement.tscn")
var enemy = preload("res://Enemies/TemplateEnemy.tscn")
var is_grid_on = false
export var placement_mode = false
export var lives = 3

func _ready(): 
	update_score_label(lives)

func _process(_delta):
	if (placement_mode):
		$TowerPlacement.show()
	else:
		$TowerPlacement.hide()

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

func update_score_label(score):
	score_label.text = "LIVES LEFT: " + str(score)

func _on_Enemy_reached_goal():
	print_debug("enemy reached goal!")
	lives -= 1
	if (lives <= 0):
		get_tree().quit()
	update_score_label(lives)
