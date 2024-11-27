extends Node3D

@onready var VRplayer = $VRplayer  # VRプレイヤーのノード

var xr_interface: XRInterface
var base_url = "http://10.96.13.139:8000/" # ベースURL
var glb_files: Array = [] # ダウンロードするGLBファイル名を保存する配列
var current_index: int = 0 # 現在ダウンロード中のGLBファイルのインデックス
var scenes: Array = [] # 生成されたシーンを保存する配列

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
	
	# ファイルリストを取得するHTTPリクエストのセットアップ
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_file_list_received)
	
	# ファイルリストのURLを指定してリクエストを送信
	var error = http_request.request_raw(base_url)
	if error != OK:
		push_error("An error occurred in the HTTP request for file list.")
		
# ファイルリストのHTTPリクエストが完了したときのコールバック関数
func _on_file_list_received(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_SUCCESS:
		# サーバーからのレスポンスをパース
		var file_list = parse_file_list(body.get_string_from_utf8())
		if file_list.size() > 0:
			# GLBファイルをリストに追加
			for file_name in file_list:
				if file_name.ends_with(".glb"):
					glb_files.append(file_name)
			
			if glb_files.size() > 0:
				# 最初のGLBファイルをダウンロード
				download_glb_file(current_index)
			else:
				print("No GLB files found.")
		else:
			print("No files found in the list.")
	else:
		print("Failed to download file list.")
		
# GLBファイルをダウンロードする関数
func download_glb_file(index: int):
	if index >= glb_files.size():
		return # 全てのファイルをダウンロードし終えた
	
	var file_url = base_url + glb_files[index]
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_glb_downloaded)
	
	var error = http_request.request_raw(file_url)
	if error != OK:
		push_error("An error occurred in the HTTP request for GLB file.")
		
# GLBファイルのHTTPリクエストが完了したときのコールバック関数
func _on_glb_downloaded(result, response_code, headers, body):
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
			
			# 生成したシーンをscenes配列に追加
			scenes.append(scene.duplicate())  # インスタンス化して配列に追加
			
			# 次のGLBファイルをダウンロード
			current_index += 1
			download_glb_file(current_index)
		else:
			print("Failed to parse GLTF data")
	else:
		print("Failed to download 3D data")
		
# ファイルリストをパースする関数
func parse_file_list(response: String) -> Array:
	var file_list = []
	var regex = RegEx.new()
	regex.compile(r'<a href="([^"]+\.glb)">')
	var result = regex.search_all(response)
	for match in result:
		file_list.append(match.get_string(1))
	return file_list

# GLBファイル名を取得する関数（Generation.gdから呼び出し用）
func get_glb_files() -> Array:
	return glb_files

# 生成されたシーンを取得する関数（他の場所で使い回すため）
func get_scenes() -> Array:
	return scenes

# 指定したインデックスのシーンをインスタンス化して返す関数
func instance_scene(index: int) -> Node:
	if index >= 0 and index < scenes.size():
		return scenes[index].duplicate()  # シーンを複製して新しいインスタンスを作成
	return null
