extends Area3D

@onready var animationPlayer = $"../../AnimationPlayer"
@onready var hint = $"../../HUD/Hint"
#var tween = create_tween()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and Global.TUTORIAL:
		animationPlayer.play("hint")
		#tween.tween_property($"../../HUD/Hint","position:x",0,1)
		hint.text = "WASD 移动，空格 跳跃"
		await get_tree().create_timer(0.1).timeout 
		animationPlayer.capture("catpure_animation",10)
		#await get_tree().create_timer(10).timeout 
		#animationPlayer.play("catpure_animation")
		pass # Replace with function body.


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and Global.TUTORIAL:
		animationPlayer.play_backwards("hint")
		#tween.tween_property($"../../HUD/Hint","position:x",-200,1)
		pass # Replace with function body.
