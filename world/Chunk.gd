extends Node3D

const CHUNK_SIZE_X = 16
const CHUNK_SIZE_Y = 8
const CHUNK_SIZE_Z = 16
const BLOCK_SIZE = 1.0

@onready var noise = FastNoiseLite.new()

func _ready():
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.1
	generate_chunk()

func generate_chunk():
	for x in CHUNK_SIZE_X:
		for z in CHUNK_SIZE_Z:
			var height = int(noise.get_noise_2d(x, z) * CHUNK_SIZE_Y)
			height = clamp(height, 1, CHUNK_SIZE_Y)

			for y in height:
				var block_container = Node3D.new()
				block_container.position = Vector3(x, y, z) * BLOCK_SIZE

				var block = StaticBody3D.new()
				
				# Visual
				var mesh = MeshInstance3D.new()
				mesh.mesh = BoxMesh.new()
				block.add_child(mesh)

				# Colisión
				var collision = CollisionShape3D.new()
				collision.shape = BoxShape3D.new()
				block.add_child(collision)

				block_container.add_child(block)
				add_child(block_container)
