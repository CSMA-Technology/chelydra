extends KinematicBody2D

onready var goal = get_tree().root.find_node("Goal", true, false).position
var path: PoolVector2Array
func _ready():
	yield(get_tree(), "idle_frame")
	print("Initial Position: " + str(position))
	path = Navigation2DServer.map_get_path(
		get_world_2d().get_navigation_map(),
		position,
		goal,
		false
		)
	goal = path[1]
	print("Path:")
	print(path)

func _physics_process(delta):
	if (position != goal):
		var movement = (goal-position).normalized()
		move_and_collide(movement *2)
