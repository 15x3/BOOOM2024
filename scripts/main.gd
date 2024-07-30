extends Node3D

# 假设 Levels 节点和 Enemies 节点为当前场景的子节点
var levels_node: Node
var enemies_node: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Global.DEATH_TIMES)
	levels_node = get_node("Level")
	enemies_node = get_node("Enemies")
	
func _on_player_death_reloaded() -> void:
	Global.DEATH_TIMES += 1 
	get_tree().reload_current_scene()
	
func _on_player_scene_filp_ordered() -> void:
	flip_levels()

func flip_levels():
	# 遍历 Levels 节点下的所有 GridMap 子节点
	for child in levels_node.get_children():
		if child is GridMap:
			# 翻转 GridMap 的 Y 轴
			child.transform.basis = Basis(Vector3(1, 0, 0), PI) * child.transform.basis
