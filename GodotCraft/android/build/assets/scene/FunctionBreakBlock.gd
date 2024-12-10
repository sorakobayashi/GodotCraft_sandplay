@tool
@icon("res://addons/godot-xr-tools/editor/icons/function.svg")
class_name XRToolsFunctionBreakBlock
extends Node3D

## Action controller button
@export var action_button_action : String = "trigger_click"


## Controller
@onready var _controller := XRHelpers.get_xr_controller(self)

# RayCastノードを取得
@onready var right_ray_cast = $"../RayCast_R"

# hilightノードを取得
@onready var assist_point = $"../AssistPoint_R"

# ボタンが押されているかどうかのフラグ
var is_button_pressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# RayCastを有効にする
	right_ray_cast.enabled = true
	
	# Monitor Grab Button
	_controller.connect("button_pressed", _on_button_pressed)
	_controller.connect("button_released", _on_button_released)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# ボタンが押されている間、break_block()を実行
	if is_button_pressed:
		break_block()
	
	highlight_block()

## Get the [XRController3D] driving this pickup.
func get_controller() -> XRController3D:
	return _controller

func _on_button_pressed(p_button) -> void:
	if p_button == action_button_action:
		is_button_pressed = true  # ボタンが押されたらフラグをtrueにする
	
func _on_button_released(_p_button) -> void:
	if _p_button == action_button_action:
		is_button_pressed = false  # ボタンが離されたらフラグをfalseにする

# 0.25はgridmapのセルのサイズの半分
# (0,-1,0)は固定またはtarget_position	
func break_block():
	if right_ray_cast.is_colliding():
		print("Right ray is colliding")
		if right_ray_cast.get_collider().has_method("destroy_block"):
			print("Destroying block")
			var pos = right_ray_cast.get_collider().global_transform.origin
			# right_ray_cast.get_collider().destroy_block(pos-right_ray_cast.get_collision_normal())
			right_ray_cast.get_collider().destroy_block(right_ray_cast.get_collision_point() - 
															right_ray_cast.get_collision_normal()*0.25 + Vector3(0, -1, 0))

func highlight_block():
	if right_ray_cast != null and assist_point != null:
		if right_ray_cast.is_colliding():
			var collided_node = right_ray_cast.get_collision_point()
			assist_point.global_transform.origin = collided_node
			assist_point.visible = true
		else:
			assist_point.visible = false
	else:
		if right_ray_cast == null:
			pass
		if assist_point == null:
			pass
