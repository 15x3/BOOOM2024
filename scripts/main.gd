extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Global.DEATH_TIMES)
	pass # Replace with function body.

func _on_player_death_reloaded() -> void:
	Global.DEATH_TIMES += 1 
	get_tree().reload_current_scene()
