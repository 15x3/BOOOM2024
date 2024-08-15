extends CanvasLayer

@onready var pixelshader : ShaderMaterial = preload("res://shaders/pixel_shader.tres")
@onready var audioStream_clean = $"../AudioStream_Clean"
@onready var audioStream_nasty = $"../AudioStream_Nasty"
@onready var kill_count = 0
signal wave_cleared
signal kill_count_reached
signal power_updated

func _ready() -> void:
	Engine.time_scale = 0.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and !Global.IS_IT_GAME_STARTED:
		Engine.time_scale = 1.0
		$MainMenu.queue_free()
		Global.IS_IT_GAME_STARTED = true
	random_progress_bar_update()
	if Global.IS_IN_MIAMI:
		$Skillbar.text = "⚡ " + str($"../MiamiTimer".time_left)
		#print($"../MiamiTimer".time_left)
	if Global.IS_IN_RANDOM:
		if !Global.RANDOM_SPECIAL_SELECTED:
			$CardPositiveWeightBar/Slected.visible = false
			$CardSpecialWeightBar/Slected.visible = true
		else:
			$CardPositiveWeightBar/Slected.visible = true
			$CardSpecialWeightBar/Slected.visible = false
	if Global.IS_BOSS_FIGHT == true:
		var boss_str_count = int($"../Boss".health / 100)
		var string_boss = "["
		for i in range(20):
			if i < boss_str_count:
				string_boss += "="
			else:
				string_boss += " "
		#var string_boss = "[" + "]
#保■捷"
		$Boss.text = string_boss
		pass

func _on_health_updated(health):
	if health >= 100:
		$Health.text = "♥ 100% [==========]"
	else:
		var health_str_count = int(health / 10)
		var health_bar_str = "["
		for i in range(10):
			if i < health_str_count:
				health_bar_str += "="
			else:
				health_bar_str += " "
		health_bar_str += "]"
		$Health.text = "♥  " + str(health) + "% " + health_bar_str

func _on_power_updated(power) -> void:
	if power >= 100:
		$Skillbar.text = "⚡ 100% [==========]"
	else:
		var power_str_count = int(power / 10)
		var power_bar_str = "["
		for i in range(10):
			if i < power_str_count:
				power_bar_str += "="
			else:
				power_bar_str += " "
		power_bar_str += "]"
		$Skillbar.text = "⚡  " + str(power) + "% " + power_bar_str

#func _on_player_shift_pressed() -> void:
	#if Global.IS_MIAMI_TRIGGERED:
		#for i in range(1,10):
			#pixelshader.set_shader_parameter("quantize_size",i)
			#await get_tree().create_timer(0.05).timeout 
		#for i in range(10,1,-1):	
			#pixelshader.set_shader_parameter("quantize_size",i)
			#await get_tree().create_timer(0.05).timeout 
		#if Global.IS_IT_MIAMI:
			#audioStream_clean.play(audioStream_nasty.get_playback_position())
			#audioStream_nasty.stop()
		#else:
			#audioStream_nasty.play(audioStream_clean.get_playback_position())
			#audioStream_clean.stop()
		#Global.IS_IT_MIAMI = !Global.IS_IT_MIAMI

func _on_enemy_spawn_or_destroyed(num) -> void:
	if Global.IS_IN_RANDOM:
		if Global.RANDOM_SPECIAL_SELECTED:
			Global.POSITIVE_WEIGHT += 10
			if Global.POSITIVE_WEIGHT >= 100:
				Global.POSITIVE_WEIGHT = 100
		else:
			Global.SPECIAL_WEIGHT += 10
			if Global.SPECIAL_WEIGHT >= 100:
				Global.SPECIAL_WEIGHT = 100
	else:
		kill_count += 1
	kill_count_update()
	if kill_count >= 3:
		kill_count_reached.emit()
		kill_count = 0
		pass
	if $EnemyLeft.visible == false:
		$EnemyLeft.visible = true
	if $Random/Label.visible == false:
		$Random/Label.visible = true
	$EnemyLeft.clear()
	Global.ENEMIES_LEFT += num
	$EnemyLeft.append_text("[shake rate=32 level=15][font size=40]剩余敌人："+str(Global.ENEMIES_LEFT)+"[/font][/shake]")
	await get_tree().create_timer(0.5).timeout 
	$EnemyLeft.clear()
	$EnemyLeft.append_text("[font size=40]剩余敌人："+str(Global.ENEMIES_LEFT)+"[/font]")
	if Global.ENEMIES_LEFT <= 0:
		emit_signal("wave_cleared")


func random_progress_bar_update():
	$CardPositiveWeightBar.value = Global.POSITIVE_WEIGHT
	$CardSpecialWeightBar.value = Global.SPECIAL_WEIGHT
	pass

func _on_main_random_rooled(result) -> void:
	if result == "health":
		$"../Player".health += 20
		if $"../Player".health > 100:
			$"../Player".health = 100
		$Random/Label.clear()
		$Random/Label.append_text("[right][font size=40]|-♥-|[/font]")
		$Random/Label2.visible = true
		_on_health_updated($"../Player".health)
	if result == "power":
		$"../Player".power += 20
		if $"../Player".power > 100:
			$"../Player".power = 100
		$Random/Label.clear()
		$Random/Label.append_text("[right][font size=40]|-⚡-|[/font]")
		$Random/Label2.visible = true
		power_updated.emit($"../Player".power)
	else:
		$Random/Label.clear()
		$Random/Label.append_text("[right][font size=40]|-×-|[/font]")
		$Random/Label2.visible = false
	
func kill_count_update():
	$Random/Label2.visible = false
	if kill_count == 0:
		$Random/Label.clear()
		$Random/Label.append_text("[shake rate=32 level=15][font size=40][right]|-----|[/right][/font][/shake]")
		await get_tree().create_timer(0.5).timeout
		$Random/Label.clear()
		$Random/Label.append_text("[right][font size=40]|-----|")
	elif kill_count == 1:
		$Random/Label.clear()
		$Random/Label.append_text("[shake rate=32 level=15][font size=40][right]|--X--|[/right][/font][/shake]")
		await get_tree().create_timer(0.5).timeout
		$Random/Label.clear()
		$Random/Label.append_text("[right][font size=40]|--X--|")
	elif kill_count ==2:
		$Random/Label.clear()
		$Random/Label.append_text("[shake rate=32 level=15][font size=40][right]|-XX--|[/right][/font][/shake]")
		await get_tree().create_timer(0.5).timeout
		$Random/Label.clear()
		$Random/Label.append_text("[right][font size=40]|-XX--|")
	else:
		pass

func _on_miami_timer_timeout() -> void:
	for i in range(1,10):
		pixelshader.set_shader_parameter("quantize_size",i)
		await get_tree().create_timer(0.05).timeout 
	Global.IS_IN_MIAMI = false
	$Skillbar.text = "⚡   0% [          ]"
	if !Global.IS_BOSS_FIGHT and !Global.IS_BOSS_TRIGGER_READY:
		audioStream_clean.play(audioStream_nasty.get_playback_position())
		audioStream_nasty.stop()
	$"../Player".damage_ampify = 1
	$"../Player".movement_speed = 7
	$"../AnimationPlayer".play("new_animation_2")
	for i in range(10,1,-1):	
		pixelshader.set_shader_parameter("quantize_size",i)
		await get_tree().create_timer(0.05).timeout 
