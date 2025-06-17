extends Node3D

@export var chunk_scene = preload("res://world/Chunk.tscn")
@export var player_scene = preload("res://player/Player.tscn")
@export var enemy_scene = preload("res://enemy/Enemy.tscn")
var crosshair_scene = preload("res://ui/Crosshair.tscn")

@export var render_distance := 2
@export var chunk_size := 16

var player: Node3D
var generated_chunks := {}
var crosshair = crosshair_scene.instantiate()
var last_player_chunk: Vector2i = Vector2i(-999, -999)  # valor inválido inicial
var chunk_pool: Array = []  # Pool de chunks reutilizables

func _ready():
	add_child(crosshair)
	player = player_scene.instantiate()
	add_child(player)
	player.global_position = Vector3(5, 10, 5)

func get_chunk_coords(pos: Vector3) -> Vector2i:
	return Vector2i(
		floor(pos.x / chunk_size),
		floor(pos.z / chunk_size)
	)

func _process(_delta):
	if not player:
		return

	var current_chunk = get_chunk_coords(player.global_position)

	if current_chunk != last_player_chunk:
		_generate_chunks_around_player(current_chunk)
		_cleanup_far_chunks(current_chunk)
		last_player_chunk = current_chunk

func _generate_chunks_around_player(center_chunk: Vector2i):
	for x in range(center_chunk.x - render_distance, center_chunk.x + render_distance + 1):
		for z in range(center_chunk.y - render_distance, center_chunk.y + render_distance + 1):
			var key = Vector2i(x, z)
			if not generated_chunks.has(key):
				var chunk: Node3D

				if chunk_pool.size() > 0:
					chunk = chunk_pool.pop_back()
				else:
					chunk = chunk_scene.instantiate()

				chunk.position = Vector3(x * chunk_size, 0, z * chunk_size)
				chunk.visible = true
				if chunk.get_parent() == null:
					add_child(chunk)
				generated_chunks[key] = chunk
				if randf() < 0.5:  # Probabilidad de spawn de enemigo
					_spawn_enemy_in_chunk(chunk)

func _cleanup_far_chunks(center_chunk: Vector2i):
	var keys_to_remove: Array = []

	for key in generated_chunks:
		var dist_x = abs(key.x - center_chunk.x)
		var dist_z = abs(key.y - center_chunk.y)
		if dist_x > render_distance or dist_z > render_distance:
			keys_to_remove.append(key)

	for key in keys_to_remove:
		var chunk = generated_chunks[key]
		chunk.visible = false
		chunk_pool.append(chunk)
		generated_chunks.erase(key)

func _spawn_enemy_in_chunk(chunk: Node3D):
	if not enemy_scene:
		return

	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	var offset_x = randf_range(1.0, chunk_size - 1.0)
	var offset_z = randf_range(1.0, chunk_size - 1.0)
	var y_position = randf_range(10.0, 15.0)

	
	enemy.global_position = chunk.position + Vector3(offset_x, y_position, offset_z)
	enemy.player = player
	
