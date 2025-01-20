extends GridMap

@export var width: int = 144
@export var height: int = 7
@export var depth: int = 104

const BLOCK_INDEX = 0
var noise = FastNoiseLite.new()

func _ready():
	noise.seed = randi()
	noise.frequency = 0.005
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	generate_terrain()

func generate_terrain():
	var offset = Vector3(width / 2.0, 0, depth / 2.0)
	for x in range(width):
		for z in range(depth):
			var noise_value = noise.get_noise_2d(x, z)
			var y = int((noise_value + 1) * height / 2)
			for i in range(y):
				set_cell_item(Vector3(x, i, z) - offset, BLOCK_INDEX)

func destroy_block(world_coordinate):
	var map_coordinate = local_to_map(world_coordinate)
	set_cell_item(map_coordinate, -1)

func place_block(world_coordinate, block_index):
	var map_coordinate = local_to_map(world_coordinate)
	set_cell_item(map_coordinate, block_index)
