extends Area3D

enum BubbleType { RANDOM, RE, MIAMI }

@export var bubble_type:BubbleType = BubbleType.RANDOM
# Called when the node enters the scene tree for the first time.
@onready var bubble_blue = preload("res://scenes/bubble_blue.material")
@onready var bubble_green = preload("res://scenes/bubble_green.material")
@onready var bubble_red = preload("res://scenes/bubble_red.material")
@onready var pixelshader : ShaderMaterial = preload("res://shaders/pixel_shader.tres")
@onready var audioStream_clean = $"../AudioStream_Clean"
@onready var audioStream_nasty = $"../AudioStream_Nasty"

signal random_triggered
signal re_triggered
signal miami_triggered

func _ready() -> void:
	pass
	if bubble_type == BubbleType.RANDOM:
		$MeshInstance3D.set_surface_override_material(0,bubble_green)
	elif bubble_type == BubbleType.RE:
		$MeshInstance3D.set_surface_override_material(0,bubble_blue)
	elif bubble_type == BubbleType.MIAMI:
		$MeshInstance3D.set_surface_override_material(0,bubble_red)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if bubble_type == BubbleType.RANDOM:
			emit_signal("random_triggered")
		elif bubble_type == BubbleType.RE:
			emit_signal("re_triggered")
		elif bubble_type == BubbleType.MIAMI:
			emit_signal("miami_triggered")


func _on_miami_triggered() -> void:
	if Global.IS_MIAMI_TRIGGERED:
		for i in range(1,10):
			pixelshader.set_shader_parameter("quantize_size",i)
			await get_tree().create_timer(0.05).timeout 
			Global.IS_IT_MIAMI = true
			audioStream_clean.play(audioStream_nasty.get_playback_position())
			audioStream_nasty.stop()
			$"../MiamiTimer".start($"../Player".power / 10)
			$"../AnimationPlayer".stop()
			self.position = Vector3(-155,40,15)
		for i in range(10,1,-1):	
			pixelshader.set_shader_parameter("quantize_size",i)
			await get_tree().create_timer(0.05).timeout 

func _on_random_triggered() -> void:
	Global.IS_IN_RANDOM = !Global.IS_IN_RANDOM
	if Global.IS_IN_RANDOM:
		for i in range(1,10):
			get_node("../HUD/PixelShader").material.set_shader_parameter("quantize_size",i)
			await get_tree().create_timer(0.05).timeout 
		get_node("../HUD/PixelShader").material.set_shader_parameter("use_palette",true)
		$"../HUD/Random/Label".visible = false
		$"../HUD/CardPositiveWeightBar".visible = true
		$"../HUD/CardSpecialWeightBar".visible = true
		for i in range(10,1,-1):
			get_node("../HUD/PixelShader").material.set_shader_parameter("quantize_size",i)
			await get_tree().create_timer(0.05).timeout 
	else:
		for i in range(1,10):
			get_node("../HUD/PixelShader").material.set_shader_parameter("quantize_size",i)
			await get_tree().create_timer(0.05).timeout 
		get_node("../HUD/PixelShader").material.set_shader_parameter("use_palette",false)
		$"../HUD/Random/Label".visible = true
		$"../HUD/CardPositiveWeightBar".visible = false
		$"../HUD/CardSpecialWeightBar".visible = false
		for i in range(10,1,-1):
			get_node("../HUD/PixelShader").material.set_shader_parameter("quantize_size",i)
			await get_tree().create_timer(0.05).timeout 


func _on_re_triggered() -> void:
	Global.IS_IN_RANDOM = !Global.IS_IN_RANDOM
	if Global.IS_IN_RANDOM:
		$HUD/PixelShader.material.set_shader_parameter("shader_parameter/use_palette",true)
		pass
	pass # Replace with function body.
