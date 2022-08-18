tool
extends Area2D

export(PackedScene) var projectile

enum RangeEnum {SHORT = 64, MEDIUM = 128, LONG = 512}
export(RangeEnum) var tower_range = RangeEnum.MEDIUM setget set_tower_range

export var debug_mode = false setget set_debug

var target_list = []

func _physics_process(_delta):
	if not target_list.empty():
		$Debug/TargetVisualizer.global_position = target_list[0].global_position

func set_tower_range(val):
	if not is_inside_tree(): yield(self, 'ready')
	tower_range = val
	$Range.shape.radius = val
	$Debug/RangeVisualizer.radius = val
	$Debug/RangeVisualizer.update()

func spawn_projectile():
	var new_projectile = projectile.instance()
	new_projectile.target = target_list[0]
	add_child(new_projectile)
	$Timer.start()

func _on_ProjectileLauncher_body_entered(body):
	target_list.append(body)
	if $Timer.is_stopped():
		spawn_projectile()


func _on_ProjectileLauncher_body_exited(body):
	target_list.erase(body)

func set_debug(val):
	if not is_inside_tree(): yield(self, 'ready')
	debug_mode = val
	if debug_mode:
		$Debug.show()
	else:
		$Debug.hide()


func _on_Timer_timeout():
	if not target_list.empty():
		spawn_projectile()
