extends CharacterBody3D

@export var walk_speed := 5.0
@export var sprint_speed := 10.0
@export var gravity := 9.8
@export var jump_speed := 5.0
@export var mouse_sensitivity := 0.002
@export var bullet_scene = preload("res://bullet/Bullet.tscn")

@onready var camera_pivot = $CameraPivot
@onready var attack_ray = $CameraPivot/Camera3D/AttackRay
@onready var attack_area = $AttackArea
@onready var muzzle = $CameraPivot/Camera3D/Muzzle

var rotation_x := 0.0
var start_position: Vector3
var is_attacking := false

# Estado de combate
var has_weapon := true  # espada cuerpo a cuerpo
var has_gun := false    # pistola o metralleta

func _ready():
	if start_position == Vector3.ZERO:
		start_position = global_position
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	attack_area.monitoring = false
	attack_area.visible = false

func _input(event):
	# Movimiento de cámara
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		rotation_x = clamp(rotation_x - event.relative.y * mouse_sensitivity, deg_to_rad(-60), deg_to_rad(60))
		camera_pivot.rotation.x = rotation_x

	# Ataque
	if event.is_action_pressed("attack"):
		if has_gun:
			shoot_bullet()
		elif has_weapon:
			start_area_attack()
		else:
			try_attack()

	# Teclas especiales
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			var paused = not get_tree().paused
			get_tree().paused = paused
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if not paused else Input.MOUSE_MODE_VISIBLE)

		if event.keycode == KEY_R:
			global_position = start_position
			velocity = Vector3.ZERO
		
		if event.keycode == KEY_G:
			has_gun = not has_gun
			has_weapon = not has_gun  # para alternar entre ambos
			print("¿Pistola equipada?: ", has_gun)

func try_attack():
	if attack_ray.is_colliding():
		var target = attack_ray.get_collider()
		if target and target.has_method("take_damage"):
			target.take_damage(20)
			print("¡Golpeaste a ", target.name)
	else:
		print("Ray no golpeó nada")

func start_area_attack():
	if is_attacking:
		return
	is_attacking = true
	attack_area.monitoring = true
	attack_area.visible = true
	print("Área de ataque activada")

	await get_tree().create_timer(0.3).timeout

	attack_area.monitoring = false
	attack_area.visible = false
	is_attacking = false

func _on_attack_area_body_entered(body):
	if is_attacking and body.has_method("take_damage"):
		print("¡Enemigo golpeado con área!")
		body.take_damage(50)

func shoot_bullet():
	if not bullet_scene:
		return

	var bullet = bullet_scene.instantiate()
	bullet.global_transform = muzzle.global_transform
	bullet.direction = -muzzle.global_transform.basis.z.normalized()
	get_tree().current_scene.add_child(bullet)

func _physics_process(delta):
	if get_tree().paused:
		return

	var input_dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	).normalized()

	var player_basis = global_transform.basis
	var move_dir = (player_basis.x * input_dir.x + player_basis.z * input_dir.y).normalized()

	var is_sprinting = Input.is_action_pressed("sprint")
	var current_speed = sprint_speed if is_sprinting else walk_speed

	velocity.x = move_dir.x * current_speed
	velocity.z = move_dir.z * current_speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_speed

	move_and_slide()
