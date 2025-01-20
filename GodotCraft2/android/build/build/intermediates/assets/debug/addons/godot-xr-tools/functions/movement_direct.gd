@tool
class_name XRToolsMovementDirect
extends XRToolsMovementProvider

## XR Tools Movement Provider for Direct Movement
##
## プレイヤーが移動するための直接移動用スクリプト。
## プレイヤーの[XROrigin3D]にアタッチされた[XRToolsPlayerBody]と連携して動作します。

## 移動順序
@export var order: int = 10

## 最大移動速度
@export var max_speed: float = 3.0

## ストレイフが可能か
@export var strafe: bool = true

## 移動方向の入力アクション
@export var input_action: String = "primary"

## 足音プレイヤーの参照
@onready var footstep_player: AudioStreamPlayer = $Audio_Walk

## コントローラーノード
@onready var _controller := XRHelpers.get_xr_controller(self)


## プレイヤーが移動中かどうかを追跡
var is_moving = false


# XRToolsクラスでis_xr_classサポートを追加
func is_xr_class(name: String) -> bool:
	return name == "XRToolsMovementDirect" or super(name)


# 移動処理
func physics_movement(_delta: float, player_body: XRToolsPlayerBody, _disabled: bool):
	# コントローラーがアクティブでない場合はスキップ
	if !_controller.get_is_active():
		return

	# デッドゾーン補正を適用した入力アクションの取得
	var dz_input_action = XRToolsUserSettings.get_adjusted_vector2(_controller, input_action)

	# プレイヤーの移動を更新
	player_body.ground_control_velocity.y += dz_input_action.y * max_speed
	if strafe:
		player_body.ground_control_velocity.x += dz_input_action.x * max_speed

	# 移動速度の制限
	var length := player_body.ground_control_velocity.length()
	if length > max_speed:
		player_body.ground_control_velocity *= max_speed / length

	# 移動中の足音
	if dz_input_action.length() > 0:
		if not is_moving:
			is_moving = true
			start_footstep()
	else:
		if is_moving:
			is_moving = false
			stop_footstep()
	


# 足音を再生開始
func start_footstep():
	if footstep_player:
		footstep_player.seek(0)
		footstep_player.play()


# 足音を停止
func stop_footstep():
	if footstep_player:
		footstep_player.stop()


# 足音ループを監視する
func _process(delta: float):
	if is_moving and footstep_player and not footstep_player.is_playing():
		# ループ再生が切れた場合、最初から再生
		footstep_player.seek(0)
		footstep_player.play()


# コンフィギュレーションの警告を確認するメソッド
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super()

	# コントローラーの存在を確認
	if !XRHelpers.get_xr_controller(self):
		warnings.append("This node must be within a branch of an XRController3D node")

	return warnings


## 左コントローラーの[XRToolsMovementDirect]ノードを検索
static func find_left(node: Node) -> XRToolsMovementDirect:
	return XRTools.find_xr_child(
		XRHelpers.get_left_controller(node),
		"*",
		"XRToolsMovementDirect"
	) as XRToolsMovementDirect


## 右コントローラーの[XRToolsMovementDirect]ノードを検索
static func find_right(node: Node) -> XRToolsMovementDirect:
	return XRTools.find_xr_child(
		XRHelpers.get_right_controller(node),
		"*",
		"XRToolsMovementDirect"
	) as XRToolsMovementDirect
