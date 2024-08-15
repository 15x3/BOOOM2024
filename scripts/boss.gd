extends CharacterBody3D

@export var path_follow: PathFollow3D
@export var duration = 40.0
@onready var rotation_speed = 2 * PI / 0.5  # 0.5秒旋转一圈
var progress_ratio = 0.378
var health = 2000
# Called when the node enters the scene tree for the first time.


func _ready() -> void:

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.IS_BOSS_FIGHT == true:
		progress_ratio += delta / duration
		#progress_ratio = progress_ratio % 1.0
		# 4.0 之后不再允许模运算
		progress_ratio = fmod(progress_ratio,1.0)
		path_follow.progress_ratio = progress_ratio
		self.position = path_follow.position
		rotation.y += rotation_speed * delta
		#change_others_gravity()
		


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
			Global.TUTORIAL = false
			$"../Tutorial".queue_free()
			$"../AnimationPlayer".play("intro_animation_2")
			await get_tree().create_timer(3).timeout
			$"../HUD/对话".text = "当然，任何游戏都不会让你这么简单地完成目标..."
			await get_tree().create_timer(3).timeout
			$"../HUD/对话".text = ""
			$"../AudioStream_Clean".play()
			# 这些东西实际上可以用动画做完，但是这里我就不跳出我的舒适区了
			$"../HUD/Intro/BooomLogo".visible = true
			await get_tree().create_timer(1.4).timeout
			$"../HUD/Intro/MyLogo".visible = true
			await get_tree().create_timer(3.6).timeout
			$"../HUD/Intro/BooomLogo".visible = false
			$"../HUD/Intro/MyLogo".visible = false
			$"../HUD/Intro/ChangeMineJamTheme".visible = true
			await get_tree().create_timer(5).timeout
			$"../HUD/Intro".queue_free()
			#print($"../AudioStream_Clean".get_playback_position())
			$"../HUD/Health".visible = true
			Global.IS_IT_GAME_STARTED = true
			Global.ENEMIES_LEFT = 0
			$"../Enemies"._on_main_enemy_spawn_ordered(5)
		elif Global.IS_BOSS_TRIGGER_READY:
			Global.IS_BOSS_FIGHT = true
			Global.IS_BOSS_TRIGGER_READY = false
			$"../AudioStream_Nasty".play()
			$"../HUD/Boss".visible = true
			$"../HUD/对话".text = ""

func change_others_gravity() -> void:
		for child in $GravityOrderArea.get_overlapping_bodies():
			if child.has_signal("gravity_change_ordered"):
				child.emit_signal("gravity_change_ordered")
		for child in $GravityOrderArea.get_overlapping_areas():
			if child.has_signal("gravity_change_ordered"):
				child.emit_signal("gravity_change_ordered")

func _on_timer_timeout() -> void:
	if Global.IS_BOSS_FIGHT == true:
		change_others_gravity()
		


func _on_main_boss_fight_ordered() -> void:
	$"../AnimationPlayer".play_backwards("intro_animation_2")
	$"../HUD/对话".text = "车子又出现在了原地，进入车内以完成游戏！"
	pass

func damage(amount):
	Audio.play("sounds/enemy_hurt.ogg")

	health -= amount
	if health <= 0:
		Global.IS_BOSS_FIGHT = false # boss fight end
		
