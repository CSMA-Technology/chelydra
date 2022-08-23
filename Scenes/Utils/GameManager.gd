extends Node

# TODO update these to get rid of template towers when necessary
enum TowerEnum { TEMPLATE_TOWER, ERASER, TEMPLATE_PROJECTILE_TOWER, STAPLER }
var towers = { 
	TowerEnum.TEMPLATE_TOWER: "res://Scenes/Towers/TemplateTower.tscn",
	TowerEnum.ERASER: "res://Scenes/Towers/Eraser.tscn",
	TowerEnum.TEMPLATE_PROJECTILE_TOWER: "res://Scenes/Towers/TemplateProjectileTower/TemplateProjectileTower.tscn",
	TowerEnum.STAPLER: "res://Scenes/Towers/Stapler.tscn"
}

enum EnemyEnum { EMAIL, DM }
var enemies = {
	EnemyEnum.EMAIL: "res://Scenes/Enemies/Email.tscn",
	EnemyEnum.DM: "res://Scenes/Enemies/DM.tscn"
}

# util function to get the scene file for each tower type
func get_tower_scene(tower_type):
	var index = TowerEnum.get(str(tower_type))
	return towers[index]

func get_enemy(enemy_type):
	var index = EnemyEnum.get(str(enemy_type))
	return enemies[index]
