extends CharacterBody3D

const JUMP_VELOCITY = 4.5

const BOB_AMP = 0.1
var BOB_FREQ = 2
var t_bob = 0.0

var speed = 5.0
var sprint_speed = 8.5
var walk_speed = 5.0
var gravity = 9.8

var bullet = load("res://player/gun/bullet.tscn")
var mag_size = 12
var reload_mag = false
var able_to_shoot = true
var instance

@onready var camera := $Head/Camera3D
@onready var gun := $Head/Camera3D/Gun
@onready var gun_barrel := $Head/Camera3D/Gun/RayCast3D
@onready var reload_timer := $ReloadTimer
@onready var reload_text := $Head/Camera3D/Reloading

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * 0.25)
		camera.rotate_x(deg_to_rad(-event.relative.y) * 0.25)
		camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("strafe_left", "strafe_right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
	if Input.is_action_just_released("sprint"):
		speed = walk_speed

	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	if Input.is_action_just_pressed("shoot"):
		if reload_mag == false and able_to_shoot == true:
			able_to_shoot = false
			mag_size -= 1
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)
			if mag_size == 0:
				able_to_shoot = false
				reload_text.visible = true
				reload_mag = true
				reload_timer.start()

	if Input.is_action_just_pressed("manual_reload"):
		if mag_size < 12:
			able_to_shoot = false
			reload_text.visible = true
			reload_mag = true
			reload_timer.start()

	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func _on_shoot_delay_timeout():
	able_to_shoot = true

func _on_reload_timer_timeout():
	able_to_shoot = true
	reload_mag = false
	mag_size = 12
	reload_text.visible = false
