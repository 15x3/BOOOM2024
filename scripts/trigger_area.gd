extends Area3D

@export var enemy_scene: PackedScene
@export var is_it_hint = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if is_it_hint:
			pass
		else:
			var enemy = enemy_scene.instantiate()
			enemy.position = $".".position
			add_child(enemy)
