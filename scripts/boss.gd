extends CharacterBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and !Global.IS_BOSS_FIGHT:
		if Global.IS_IT_GAME_END:
			$"../HUD/Pause-button".visible = true
			Audio.play("sounds/DevolverDigital.ogg")
			$"../HUD/对话".text = "然后勒，后面咱们就收个尾，再留个悬念"
			await get_tree().create_timer(3).timeout
			$"../HUD/对话".text = "我感觉啊，这（游戏）我们起码可以搞4、5年"
			await get_tree().create_timer(3).timeout
			$"../HUD/对话".text = ""
			await get_tree().create_timer(2).timeout
			$"../HUD/对话".text = "咋样？我的意思是... ...咋样？牛逼吧？"
			await get_tree().create_timer(3).timeout
			$"../HUD/对话".text = "这主意蠢爆了，绝对行不通"
			await get_tree().create_timer(3).timeout
			$"../HUD/对话".text = "你能想得出来，说明你就一傻X"
			await get_tree().create_timer(3).timeout
			$"../HUD/对话".text = "这玩意谁特么能想得出来？"
			await get_tree().create_timer(3).timeout
			$"../HUD/对话".text = "说了是我啊，我想出来的"
			await get_tree().create_timer(1).timeout
			$"../HUD/对话".text = "也就你个傻Ⅹ才想得....."
			await get_tree().create_timer(2).timeout
			$"../HUD/对话".queue_free()
			$"../HUD/Pause-button".queue_free()
		elif Global.TUTORIAL:
			$"../AnimationPlayer".play("intro_animation_2")
			await get_tree().create_timer(3).timeout
			$"../HUD/对话".text = "当然，游戏从来不会让你简单地完成任务..."
			await get_tree().create_timer(3).timeout
			$"../HUD/对话".text = ""
