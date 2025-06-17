extends Label3D

var float_speed := 2.0
var lifetime := 1.0

func set_damage(amount: int):
	text = str(amount)

func _process(delta):
	translate(Vector3.UP * float_speed * delta)
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
