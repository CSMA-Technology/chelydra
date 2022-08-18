extends KinematicBody2D

class_name TemplateEnemy

onready var goal = get_tree().root.find_node("Goal", true, false).global_position
var path: PoolVector2Array
var next_destination_idx

export var debug_mode = false setget set_debug
export var health = 100

const ARRIVAL_BUFFER = 10
const SPEED = 3

signal reached_goal(damage)

func set_debug(val: bool):
	debug_mode = val
	if debug_mode:
		$Debug.show()
		$Debug/PathLine2d.set_as_toplevel(true)
	else:
		$Debug.hide()
		$Debug/PathLine2d.set_as_toplevel(false)

func _physics_process(_delta):
	if goal.distance_to(global_position) < ARRIVAL_BUFFER:
		handle_goal_arrival()
	if not path:
		update_path()
	if path.size() > 0:
		if (path[next_destination_idx].distance_to(global_position)) < ARRIVAL_BUFFER:
			if path.size() > next_destination_idx + 1:
				next_destination_idx += 1

		var direction = (path[next_destination_idx] - global_position).normalized()
		var movement = direction * SPEED
		$Debug/MovementLine2d.points = PoolVector2Array([Vector2(0,0), direction * 100])
		move_and_collide(movement)

func update_path():
	Navigation2DServer.map_force_update(get_world_2d().get_navigation_map())
	path = Navigation2DServer.map_get_path(get_world_2d().get_navigation_map(), global_position, goal, false)
	$Debug/PathLine2d.points = path
	next_destination_idx = 0

func handle_goal_arrival():
	emit_signal("reached_goal", 1)
	queue_free()

func take_damage(damage):
	health -= damage
	if (health <= 0):
		queue_free()
