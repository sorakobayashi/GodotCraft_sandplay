extends GridMap

# グリッドのサイズ
@export var width: int = 80
@export var height: int = 20
@export var depth: int = 80

# 地形生成に使用するブロックのインデックス（必要に応じて適切な値に変更してください）
const BLOCK_INDEX = 0

# FastNoiseLite ノイズ生成器
var noise = FastNoiseLite.new()

# ノードが準備完了した時に呼ばれる関数
func _ready():
	# ノイズのパラメータ設定
	noise.seed = randi()  # ランダムシード
	noise.frequency = 0.005  # 周波数
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH # ノイズの種類
	generate_terrain()

# 地形の中心を (0, 0, 0) にするように地形を生成する関数
func generate_terrain():
	# 地形のオフセットを計算
	var offset = Vector3(width / 2.0, 0, depth / 2.0)

	for x in range(width):
		for z in range(depth):
			# ノイズ値を取得して高さを計算
			var noise_value = noise.get_noise_2d(x, z)  # 2Dノイズを使用
			var y = int((noise_value + 1) * height / 2)  # 高さをスケーリング（ノイズ値は-1から1の範囲）
			for i in range(y):
				var map_coordinate = Vector3(x, i, z) - offset
				set_cell_item(map_coordinate, BLOCK_INDEX)

func destroy_block(world_coordinate):
	var map_coordinate = local_to_map(world_coordinate)
	set_cell_item(map_coordinate, -1)

func place_block(world_coordinate, block_index):
	var map_coordinate = local_to_map(world_coordinate)
	set_cell_item(map_coordinate, block_index)
