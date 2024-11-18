@tool
@icon("res://addons/godot-xr-tools/editor/icons/function.svg")
class_name XRToolsFunctionCreateBlock
extends Node3D

## Action controller button
@export var action_button_action : String = "trigger_click"

## Controller
@onready var _controller := XRHelpers.get_xr_controller(self)

# RayCastノードを取得
@onready var left_ray_cast = $"../RayCast_L"

# hilightノードを取得
@onready var assist_point = $"../AssistPoint_L"

@onready var laser = $"../Laser_L"

# ボタンが押されているかどうかのフラグ
var is_button_pressed = false

# 落下中のブロックのリスト
var falling_blocks = []

# 落下間隔のタイマー
var fall_timer = 0.0
var fall_interval = 0.5  # 0.5秒ごとに落下

# Called when the node enters the scene tree for the first time.
func _ready():
	# RayCastを有効にする
	left_ray_cast.enabled = true
	
	# Monitor Grab Button
	_controller.connect("button_pressed", _on_button_pressed)
	_controller.connect("button_released", _on_button_released)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# ボタンが押されている間、create_block()を実行
	if is_button_pressed:
		create_block()
	
	highlight_block()

	# タイマーを更新
	fall_timer += delta

	# 一定間隔ごとに落下中のブロックを更新
	if fall_timer >= fall_interval:
		fall_timer = 0.0
		update_falling_blocks()

## Get the [XRController3D] driving this pickup.
func get_controller() -> XRController3D:
	return _controller

func _on_button_pressed(p_button) -> void:
	if p_button == action_button_action:
		is_button_pressed = true  # ボタンが押されたらフラグをtrueにする
	
func _on_button_released(_p_button) -> void:
	if _p_button == action_button_action:
		is_button_pressed = false  # ボタンが離されたらフラグをfalseにする

# 地形にブロックを置く
func create_block():
	if left_ray_cast.is_colliding():
		if left_ray_cast.get_collider().has_method("place_block"):
			left_ray_cast.get_collider().place_block(left_ray_cast.get_collision_point() + 
													 left_ray_cast.get_collision_normal() * 0.25 + Vector3(0, -1, 0), 0)
	else:
		# RayCastが何も衝突していない場合、laserノードの位置でplace_blockを実行
		var grid_map = get_node("/root/World/GridMap")
		if grid_map.has_method("place_block"):
			var block_position = laser.global_transform.origin
			grid_map.place_block(block_position, 0)
			# ブロックの落下を開始
			start_block_fall(grid_map, block_position)
			
func highlight_block():
	if left_ray_cast.is_colliding():
		var collided_node = left_ray_cast.get_collision_point()
		# Hilightノードを衝突ノードの位置に移動して表示
		assist_point.global_transform.origin = collided_node
		assist_point.visible = true
	else:
		# RayCastが何もヒットしていない場合、Hilightノードを非表示にする
		assist_point.visible = false

# ブロックの落下を開始
func start_block_fall(grid_map, initial_position):
	var block = {
		"node": grid_map,
		"position": initial_position
	}
	falling_blocks.append(block)

# 落下中のブロックの位置を更新
func update_falling_blocks():
	for block in falling_blocks:
		var grid_map = block["node"]
		var current_position = block["position"]
		var new_position = current_position + Vector3(0, -1, 0)

		# y座標が5以上の時のみ落下させる
		if new_position.y <= 5:
			# y = 4に固定してブロックを配置
			block["position"].y = 5
		else:
			# 現在の位置のブロックを削除
			grid_map.set_cell_item(grid_map.local_to_map(current_position), -1)
			# 新しい位置にブロックを置く
			grid_map.set_cell_item(grid_map.local_to_map(new_position), 0)

			# ブロックの位置を更新
			block["position"] = new_position
