
extends Node3D

# ノードの取得
@onready var left_ray_cast = $XROrigin3D/LeftHand/RayCast
@onready var right_ray_cast = $XROrigin3D/RightHand/RayCast

@export var trigger_click :String = "trigger_click"

func _ready():
	# RayCastを有効にする
	left_ray_cast.enabled = true
	right_ray_cast.enabled = true

func _process(delta):
	#handle_block_interaction()
	debugblock()
func debugblock():
	if left_ray_cast.is_colliding():
			print("Left ray is colliding")
			if left_ray_cast.get_collider().has_method("destroy_block"):
				print("Destroying block")
				left_ray_cast.get_collider().destroy_block(left_ray_cast.get_collision_point() -
															left_ray_cast.get_collision_normal())

# ブロックのインタラクション処理
#func handle_block_interaction():
	if trigger_click:
		print("Trigger pressed")
		if left_ray_cast.is_colliding():
			print("Left ray is colliding")
			if left_ray_cast.get_collider().has_method("destroy_block"):
				print("Destroying block")
				left_ray_cast.get_collider().destroy_block(left_ray_cast.get_collision_point() -
															left_ray_cast.get_collision_normal())
		elif right_ray_cast.is_colliding():
			print("Right ray is colliding")
			if right_ray_cast.get_collider().has_method("destroy_block"):
				print("Destroying block")
				right_ray_cast.get_collider().destroy_block(right_ray_cast.get_collision_point() -
															right_ray_cast.get_collision_normal())


	if Input.is_action_pressed("grip_click"):  # グリップで追加
		if left_ray_cast.is_colliding():
			if left_ray_cast.get_collider().has_method("place_block"):
				left_ray_cast.get_collider().place_block(left_ray_cast.get_collision_point() +
														  left_ray_cast.get_collision_normal(), 0)
		elif right_ray_cast.is_colliding():
			if right_ray_cast.get_collider().has_method("place_block"):
				right_ray_cast.get_collider().place_block(right_ray_cast.get_collision_point() +
														   right_ray_cast.get_collision_normal(), 0)
