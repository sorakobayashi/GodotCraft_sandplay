@tool
@icon("res://addons/godot-xr-tools/editor/icons/function.svg")
class_name XRToolsFunctionCreateBlock
extends Node3D

@export var action_button_action : String = "trigger_click"

@onready var _controller := XRHelpers.get_xr_controller(self)
@onready var left_ray_cast = $"../RayCast_L"
@onready var assist_point = $"../AssistPoint_L"
@onready var laser = $"../Laser_L"

var is_button_pressed = false
var falling_blocks = []
var fall_timer = 0.0
var fall_interval = 0.5

func _ready():
	left_ray_cast.enabled = true
	_controller.connect("button_pressed", _on_button_pressed)
	_controller.connect("button_released", _on_button_released)

func _process(delta):
	if is_button_pressed:
		create_block()
	highlight_block()
	fall_timer += delta
	if fall_timer >= fall_interval:
		fall_timer = 0.0
		update_falling_blocks()

func get_controller() -> XRController3D:
	return _controller

func _on_button_pressed(p_button) -> void:
	if p_button == action_button_action:
		is_button_pressed = true
	
func _on_button_released(_p_button) -> void:
	if _p_button == action_button_action:
		is_button_pressed = false

func create_block():
	if left_ray_cast.is_colliding():
		if left_ray_cast.get_collider().has_method("place_block"):
			left_ray_cast.get_collider().place_block(left_ray_cast.get_collision_point() + 
													 left_ray_cast.get_collision_normal() * 0.25 + Vector3(0, -1, 0), 0)
	else:
		var grid_map = get_node("/root/World/GridMap")
		if grid_map.has_method("place_block"):
			var block_position = laser.global_transform.origin
			grid_map.place_block(block_position, 0)
			start_block_fall(grid_map, block_position)
			
func highlight_block():
	if left_ray_cast != null and assist_point != null:
		if left_ray_cast.is_colliding():
			var collided_node = left_ray_cast.get_collision_point()
			assist_point.global_transform.origin = collided_node
			assist_point.visible = true
		else:
			assist_point.visible = false
	else:
		if left_ray_cast == null:
			pass
		if assist_point == null:
			pass

func start_block_fall(grid_map, initial_position):
	var block = {
		"node": grid_map,
		"position": initial_position
	}
	falling_blocks.append(block)

func update_falling_blocks():
	for block in falling_blocks:
		var grid_map = block["node"]
		var current_position = block["position"]
		var new_position = current_position + Vector3(0, -1, 0)

		if new_position.y <= 5:
			block["position"].y = 5
		else:
			grid_map.set_cell_item(grid_map.local_to_map(current_position), -1)
			grid_map.set_cell_item(grid_map.local_to_map(new_position), 0)
			block["position"] = new_position
