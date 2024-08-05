extends CanvasLayer

@onready var pixelshader : ShaderMaterial = preload("res://shaders/pixel_shader.tres")

func _on_health_updated(health):
	$Health.text = str(health) + "%"

func _on_player_shift_pressed() -> void:
	for i in range(1,10):
		pixelshader.set_shader_parameter("quantize_size",i)
		await get_tree().create_timer(0.05).timeout 
	for i in range(10,1,-1):	
		pixelshader.set_shader_parameter("quantize_size",i)
		await get_tree().create_timer(0.05).timeout 
	
