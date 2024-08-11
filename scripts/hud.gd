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
	if Global.IS_IN_RANDOM:
		if Global.RANDOM_SPECIAL_SELECTED:
			$CardPositiveWeightBar/Slected.visible = false
			$CardSpecialWeightBar/Slected.visible = true
		else:
			$CardPositiveWeightBar/Slected.visible = true
			$CardSpecialWeightBar/Slected.visible = false

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

func _on_player_shift_pressed() -> void:
	if Global.IS_MIAMI_TRIGGERED:
		for i in range(1,10):
			pixelshader.set_shader_parameter("quantize_size",i)
			await get_tree().create_timer(0.05).timeout 
		for i in range(10,1,-1):	
			pixelshader.set_shader_parameter("quantize_size",i)
			await get_tree().create_timer(0.05).timeout 
		if Global.IS_IT_MIAMI:
			audioStream_clean.play(audioStream_nasty.get_playback_position())
			audioStream_nasty.stop()
		else:
			audioStream_nasty.play(audioStream_clean.get_playback_position())
			audioStream_clean.stop()
		Global.IS_IT_MIAMI = !Global.IS_IT_MIAMI

func _on_enemy_spawn_or_destroyed(num) -> void:
	kill_count += 1
	kill_count_update()
	if kill_count >= 3:
		kill_count_reached.emit()
		kill_count = 0
		pass
	if $EnemyLeft.visible == false:
		$EnemyLeft.visible = true
	if $Random.visible == false:
		$Random.visible = true
	$EnemyLeft.clear()
	Global.ENEMIES_LEFT += num
	$EnemyLeft.append_text("[shake rate=32 level=15][font size=40]剩余敌人："+str(Global.ENEMIES_LEFT)+"[/font][/shake]")
	await get_tree().create_timer(0.5).timeout 
	$EnemyLeft.clear()
	$EnemyLeft.append_text("[font size=40]剩余敌人："+str(Global.ENEMIES_LEFT)+"[/font]")
	if Global.ENEMIES_LEFT <= 0:
		emit_signal("wave_cleared")
	if Global.IS_IN_RANDOM:
		if Global.POSITIVE_WEIGHT:
			Global.POSITIVE_WEIGHT += 10
		else:
			Global.SPECIAL_WEIGHT += 10

func random_progress_bar_update():
	$CardPositiveWeightBar.value = Global.POSITIVE_WEIGHT
	$CardSpecialWeightBar.value = Global.SPECIAL_WEIGHT
	pass


func _on_main_random_rooled(result) -> void:
	if result == "health":
		$"../Player".health += 10
	if result == "power":
		$"../Player".power += 10
		power_updated.emit($"../Player".power)
	else:
		pass
	
func kill_count_update():
	if kill_count == 0:
		$Random/Label.clear()
		$Random/Label.append_text("[shake rate=32 level=15][font size=40][right]|-----|[/right][/font][/shake]")
		await get_tree().create_timer(0.5).timeout
		$Random/Label.clear()
		$Random/Label.append_text("[font size=40][right]|-----|")
	elif kill_count == 1:
		$Random/Label.clear()
		$Random/Label.append_text("[shake rate=32 level=15][font size=40][right]|--X--|[/right][/font][/shake]")
		await get_tree().create_timer(0.5).timeout
		$Random/Label.clear()
		$Random/Label.append_text("[font size=40][right]|--X--|")
	elif kill_count ==2:
		$Random/Label.clear()
		$Random/Label.append_text("[shake rate=32 level=15][font size=40][right]|-XX--|[/right][/font][/shake]")
		await get_tree().create_timer(0.5).timeout
		$Random/Label.clear()
		$Random/Label.append_text("[font size=40][right]|-XX--|")
	else:
		pass
