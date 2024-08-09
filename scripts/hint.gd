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
		#tween.tween_property($"../../HUD/Hint","position",0,1)
		animationPlayer.play("hint")
		hint.text = "靠近白色保时捷来结束游戏！"
		pass # Replace with function body.


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and Global.TUTORIAL:
		#tween.tween_property($"../../HUD/Hint","position",-200,1)
		animationPlayer.play_backwards("hint")
		pass # Replace with function body.
