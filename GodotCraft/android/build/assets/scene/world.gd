extends Node3D

@onready var VRplayer = $VRplayer #　VRプレイヤーのノード

var xr_interface: XRInterface

func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected")
	
	# HTTPリクエストが完了したときのシグナルを接続
	# HTTPRequestノードをシーンに追加
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_request_completed)
	
	# 3DモデルのURLを指定してリクエストを送信
	var url = "http://10.96.13.139:8000/majo.glb"
	var error = http_request.request_raw(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		
# HTTPリクエストが完了したときのコールバック関数
func _on_request_completed(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_SUCCESS:
		# GLTFデータを解析してシーンに追加
		var gltf_state = GLTFState.new()
		var gltf_doc = GLTFDocument.new()
		var error = gltf_doc.append_from_buffer(body, "", gltf_state)
		if error == OK:
			var scene = gltf_doc.generate_scene(gltf_state)
			
			# プレイヤーの位置を取得して3Dモデルを配置
			var VRplayer_position = VRplayer.global_transform.origin
			scene.global_transform.origin = VRplayer_position
			
			add_child(scene)
		else:
			print("Failed to parse GLTF data")
	else:
		print("Failed to download 3D data")
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
