extends Node3D

const SPEED = 250.0

@onready var bullet_mesh := $MeshInstance3D
@onready var ray := $RayCast3D
@onready var particles := $GPUParticles3D

func _process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding():
		bullet_mesh.visible = false
		particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()

func _on_bullet_timer_timeout():
	queue_free()
