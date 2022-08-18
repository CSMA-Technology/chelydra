extends Area2D

export (int) var speed = 1000
export (int, -1, 1) var vertical_direction = 1
export (int) var damage = 25

func _physics_process(delta):
	global_position.x += speed * vertical_direction * delta

func _on_TemporaryProjectile_body_entered(body):
	if body is TemplateEnemy:
		body.take_damage(damage)
		queue_free()
