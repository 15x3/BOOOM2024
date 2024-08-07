extends Node

@export var enemy_scene: PackedScene

func spawn_enemies() -> void:
		var enemy = enemy_scene.instantiate()
		var enemy_spawn_location = get_node("../SpawnPath/PathFollow3D")
		enemy_spawn_location.progress_ratio = randf()
		enemy.global_transform.origin = enemy_spawn_location.position
		add_child(enemy)

func _on_main_enemy_spawn_ordered(num) -> void:
	for i in range(num):
		spawn_enemies()
		await get_tree().create_timer(0.05).timeout 
		Global.ENEMIES_LEFT += 1
		$"../HUD/EnemyLeft".clear()
		$"../HUD/EnemyLeft".append_text("[shake rate=16 level=15][font size=40]剩余敌人："+str(Global.ENEMIES_LEFT)+"[/font][/shake]")
