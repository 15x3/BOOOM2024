extends Area3D

# 定义信号
signal player_entered(player)

func _ready() -> void:
	
	pass

# 这个函数会在玩家进入Area3D时被调用
func _on_Area3D_body_entered(body):
	# 检查进入的物体是否是玩家
	if body.is_in_group("players"): # 假设玩家物体属于"players"组
		emit_signal("player_entered", body)
		print("entered")
