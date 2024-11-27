extends CanvasLayer

@onready var world_node = get_node("/root/World")
@onready var glb_name = world_node.get_glb_files()

@onready var vrplayer = get_node("/root/World/VRplayer/XROrigin3D/LeftHand/Laser_L")

func _ready():
	$Generation/ColorRect/VBoxContainer/Button0.text = glb_name[0]
	$Generation/ColorRect/VBoxContainer/Button1.text = glb_name[1]

func _on_button0_pressed():
	var new_instance = world_node.instance_scene(0)  # 新しいインスタンスを作成
	if new_instance:
		new_instance.global_transform.origin = vrplayer.global_transform.origin
		world_node.add_child(new_instance)

func _on_button1_pressed():
	var new_instance = world_node.instance_scene(1)  # 新しいインスタンスを作成
	if new_instance:
		new_instance.global_transform.origin = vrplayer.global_transform.origin
		world_node.add_child(new_instance)
