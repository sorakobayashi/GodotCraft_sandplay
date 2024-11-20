extends Control

@onready var majo_button = $ColorRect/VBoxContainer/MajoGeneration
@onready var world_node = get_node("res://scene/world.tscn") # Worldノードへのパスを指定

func _ready():
	# ボタンのpressedシグナルを関数に接続する
	majo_button.pressed.connect(_on_majo_button_pressed)

func _on_majo_button_pressed():
	# redball.tscnをインスタンス化して(0, 20, 0)の位置に配置
	var redball_scene = preload("res://scene/redball.tscn")
	var redball_instance = redball_scene.instance()
	redball_instance.global_transform.origin = Vector3(0, 20, 0)
	
	# Worldノードに追加
	world_node.add_child(redball_instance)

# 毎フレーム呼び出される関数。'delta'は前のフレームからの経過時間
func _process(delta):
	pass
