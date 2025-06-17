extends CharacterBody3D

@export var max_health: int = 100
@export var gravity: float = 30.0
@export var speed: float = 4.0
@export var detection_range: float = 20.0
@export var damage_color_time := 0.2
@export var knockback_strength := 5.0

@onready var mesh = $Mesh  # Ajusta si tu MeshInstance3D se llama distinto
@onready var health_bar = $Node3D/ProgressBar

var current_health: int
var player: Node3D
var original_color : Color
var damage_timer := 0.0
var knockback_velocity := Vector3.ZERO

func _ready():
	current_health = max_health
	original_color = mesh.get_active_material(0).albedo_color
	

func take_damage(amount: int, source_direction: Vector3 = Vector3.ZERO):
	current_health -= amount
	

	# Cambiar color temporalmente
	mesh.get_active_material(0).albedo_color = Color.RED
	damage_timer = damage_color_time

	# Aplicar retroceso
	if source_direction != Vector3.ZERO:
		knockback_velocity = -source_direction.normalized() * knockback_strength

	if current_health <= 0:
		die()

func die():
	# Aquí puedes manejar la lógica de muerte del enemigo
	print("Enemy died")
	queue_free()  # Elimina el enemigo de la escena



func _process(delta):
	if damage_timer > 0:
		damage_timer -= delta
		if damage_timer <= 0:
			mesh.get_active_material(0).albedo_color = original_color

	if health_bar and get_viewport().get_camera_3d():
		$Node3D.look_at(get_viewport().get_camera_3d().global_position, Vector3.UP)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if knockback_velocity.length() > 0.1:
		velocity += knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, delta * 10)

	elif player and global_position.distance_to(player.global_position) <= detection_range:
		var direction = (player.global_position - global_position).normalized()
		direction.y = 0
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()
