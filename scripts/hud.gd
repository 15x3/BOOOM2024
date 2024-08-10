extends CanvasLayer

@onready var pixelshader : ShaderMaterial = preload("res://shaders/pixel_shader.tres")
@onready var audioStream_clean = $"../AudioStream_Clean"
@onready var audioStream_nasty = $"../AudioStream_Nasty"

signal wave_cleared

func _ready() -> void:
	Engine.time_scale = 0.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and !Global.IS_IT_GAME_STARTED:
		Engine.time_scale = 1.0
		$MainMenu.queue_free()
		Global.IS_IT_GAME_STARTED = true

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
	if $EnemyLeft.visible == false:
		$EnemyLeft.visible = true
	$EnemyLeft.clear()
	Global.ENEMIES_LEFT += num
	$EnemyLeft.append_text("[shake rate=32 level=15][font size=40]剩余敌人："+str(Global.ENEMIES_LEFT)+"[/font][/shake]")
	await get_tree().create_timer(0.5).timeout 
	$EnemyLeft.clear()
	$EnemyLeft.append_text("[font size=40]剩余敌人："+str(Global.ENEMIES_LEFT)+"[/font]")
	if Global.ENEMIES_LEFT <= 0:
		emit_signal("wave_cleared")

		
