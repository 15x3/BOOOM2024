extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	# 这算硬编码了，别学这个
	if !Global.TUTORIAL and body.is_in_group("player") and Global.IS_IT_GAME_STARTED:
		$SHIFT.queue_free()
		$CollisionShape3D.queue_free()
		$"../../HUD/Hint".text = "按 [E] 改变面前物体/敌人的重力"
		$"../../AnimationPlayer".play("hint")
		await get_tree().create_timer(5).timeout
		$"../../AnimationPlayer".play_backwards("hint")
		$"../../HUD/Hint".text = "双击 [E] 改变自身重力"
		$"../../AnimationPlayer".play("hint")
		await get_tree().create_timer(5).timeout
		$"../../AnimationPlayer".play_backwards("hint")
		await get_tree().create_timer(2).timeout
		queue_free()
	
