extends CanvasLayer

@onready var pixelshader : ShaderMaterial = preload("res://shaders/pixel_shader.tres")

signal wave_cleared

func _on_health_updated(health):
	$Health.text = str(health) + "%"

func _on_player_shift_pressed() -> void:
	for i in range(1,10):
		pixelshader.set_shader_parameter("quantize_size",i)
		await get_tree().create_timer(0.05).timeout 
	for i in range(10,1,-1):	
		pixelshader.set_shader_parameter("quantize_size",i)
		await get_tree().create_timer(0.05).timeout 
	
func _on_enemy_spawn_or_destroyed(num) -> void:
	$EnemyLeft.clear()
	Global.ENEMIES_LEFT += num
	$EnemyLeft.append_text("[shake rate=16 level=15][font size=40]剩余敌人："+str(Global.ENEMIES_LEFT)+"[/font][/shake]")
	if Global.ENEMIES_LEFT <= 0:
		emit_signal("wave_cleared")

		
