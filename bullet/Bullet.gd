extends RigidBody3D

@export var speed := 60.0
@export var damage := 20
var direction := Vector3.FORWARD
var has_hit := false  # Para evitar múltiples impactos

@onready var hit_area = $HitBox

func _ready():
	add_to_group("player_attack")

func _process(delta):
	if not has_hit:
		global_position += direction * speed * delta

func _on_hit_box_body_entered(body: Node3D) -> void:
	if has_hit:
		return

	if body.has_method("take_damage"):
		var impact_dir = direction
		body.take_damage(damage, impact_dir)

	has_hit = true
	linear_velocity = Vector3.ZERO  # Detener movimiento físico
	sleeping = true                 # Detener simulación física
	queue_free()                    # Destruir proyectil
