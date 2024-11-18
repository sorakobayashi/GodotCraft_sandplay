@tool
@icon("res://addons/godot-xr-tools/editor/icons/function.svg")
class_name XRToolsFunctionErase
extends RayCast3D

## Action controller button
@export var action_button_action : String = "trigger_click"

@onready var left_hand = $LeftHand
@onready var ray_cast_3d = $LeftHand/RayCast3D
@onready var line_renderer = $ImmediateGeometry

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta: float) -> void:
	line_renderer.clear()
	line_renderer.begin(Mesh.PRIMITIVE_LINES, null)
	
	# レイの起点
	var from = global_transform.origin
	# 衝突している場合の終点
	var to = is_colliding() ? get_collision_point() : global_transform.origin + global_transform.basis.z * cast_to.length()
	line_renderer.add_vertex(from)
	line_renderer.add_vertex(to)
	line_renderer.end()
