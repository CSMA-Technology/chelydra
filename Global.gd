extends Node

var template_tower = preload("res://Scenes/Towers/TemplateTower.tscn")
var eraser = preload("res://Scenes/Towers/Eraser.tscn")
var template_projectile_tower = preload("res://Scenes/Towers/TemplateProjectileTower/TemplateProjectileTower.tscn") 

enum TowerEnum { TEMPLATE_TOWER, ERASER, TEMPLATE_PROJECTILE_TOWER }

var towers = {
	TowerEnum.TEMPLATE_TOWER: template_tower,
	TowerEnum.ERASER: eraser,
	TowerEnum.TEMPLATE_PROJECTILE_TOWER: template_projectile_tower
}

func get_tower(tower_type):
	var index = TowerEnum.get(str(tower_type))
	return towers[index]
