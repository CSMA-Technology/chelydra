extends KinematicBody2D

var target
export var speed = 10
export var damage = 50

func _ready():
	hide()
	# Waiting for an idle frame before revealing prevents a single frame of pointing in the wrong direction before the look_at call in physics_process
	yield(get_tree(), "idle_frame")
	show()

func _physics_process(delta):
	if not target: return
	if not is_instance_valid(target): 
		queue_free()
		return
	var direction = (target.global_position - global_position).normalized()
	var movement = direction * speed
	look_at(target.global_position)
	var collision = move_and_collide(movement)
	if collision:
		collision.collider.take_damage(damage)
		queue_free()
