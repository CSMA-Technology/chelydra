extends KinematicBody2D

class_name TemplateEnemy

onready var goal = get_tree().root.find_node("Goal", true, false).global_position
var path: PoolVector2Array
var next_destination_idx

export var debug_mode = false setget set_debug
export var health = 100
export var speed = 3

const ARRIVAL_BUFFER = 10

signal reached_goal(damage)
#
#func _ready():
#	Navigation2DServer.connect("map_changed", self, "update_path", [], CONNECT_DEFERRED)

func set_debug(val: bool):
	debug_mode = val
	if debug_mode:
		$Debug.show()
		$Debug/PathLine2d.set_as_toplevel(true)
	else:
		$Debug.hide()
		$Debug/PathLine2d.set_as_toplevel(false)

func _physics_process(delta):
	if goal.distance_to(global_position) < ARRIVAL_BUFFER:
		handle_goal_arrival()
#	if not path:
#		update_path(get_world_2d().get_navigation_map())
	if path.size() > 0:
		if (path[next_destination_idx].distance_to(global_position)) < ARRIVAL_BUFFER:
			if path.size() > next_destination_idx + 1:
				next_destination_idx += 1

		var direction = (path[next_destination_idx] - global_position).normalized()
		var movement = direction * speed
		
		move_and_slide(movement)
		if debug_mode:
			$Debug/MovementLine2d.points = PoolVector2Array([Vector2(0,0), direction * 100])
			$Debug/PathLine2d.points = path
	else:
		print(path)

# pop_front is useful because when alreayd moving along a grid, we may be past the nearest grid point, and thus starting a new path would make us backtrack
func set_path(new_path, pop_front=false):
	path = new_path
	if pop_front:
		path.remove(0)
	next_destination_idx = 0

func handle_goal_arrival():
	emit_signal("reached_goal", 1)
	queue_free()

func take_damage(damage):
	flash_red()
	health -= damage
	if (health <= 0):
		queue_free()


func flash_red():
	$Sprite.material.set_shader_param("turn_red", true)
	yield(get_tree().create_timer(0.05), "timeout")
	$Sprite.material.set_shader_param("turn_red", false)
