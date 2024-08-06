extends Node3D

enum CardType {
	NEGATIVE,
	POSITIVE,
	POSITIVE_SPECIAL
}
# 定义卡池的大小和种类数量
const TOTAL_CARDS = 20
const NEGATIVE_CARDS = 10
const POSITIVE_CARDS = 7
const POSITIVE_SPECIAL_CARDS = 3

# 概率控制变量
var positive_weight = 0.5 # 抽中正面卡的权重
var special_weight = 1.0 - positive_weight # 抽中正面卡时抽中强化卡的权重
@onready var positive_weight_bar = $HUD/CardPositiveWeightBar
@onready var special_weight_bar = $HUD/CardSpecialWeightBar
@onready var pixelshader : ShaderMaterial = preload("res://shaders/pixel_shader.tres")
@export var enemy_scene : PackedScene


# 初始化卡池
var cards: Array = []
var card_info: Dictionary = {}

# 假设 Levels 节点和 Enemies 节点为当前场景的子节点
var levels_node: Node
var enemies_node: Node
var cardpool = CardPool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Global.DEATH_TIMES)
	levels_node = get_node("Level")
	enemies_node = get_node("Enemies")
	initialize_card_pool()
	
	# RE - 重启时的四次选择
	if Global.RESET_BY_GAME_OVER >= 1:
		pass
	if Global.RESET_BY_GAME_OVER >= 2:
		pass
	if Global.RESET_BY_GAME_OVER >= 3:
		pass
	if Global.RESET_BY_GAME_OVER >= 4:
		pass
	
func _on_player_death_reloaded() -> void:
	Global.DEATH_TIMES += 1 
	get_tree().reload_current_scene()
	
func _on_player_scene_filp_ordered() -> void:
	flip_levels()

func _on_player_cardroll_ordered() -> void:
	for i in range(1, 4):  # 循环从1到3
		var child_name = "CardDetails" + str(i)
		var results = draw_card()  # 假设 draw_card() 返回卡牌信息，比如卡牌名称或描述等
		var card_details = find_child(child_name)
		
		if card_details and card_details is RichTextLabel:
			# 设置富文本框的文本内容
			card_details.bbcode_text = "[b]Card:[/b] " + str(results)
		else:
			print("RichTextLabel not found or wrong type for:", child_name)

func flip_levels():
	# 遍历 Levels 节点下的所有 GridMap 子节点
	for i in range(1,10):
		pixelshader.set_shader_parameter("quantize_size",i)
		await get_tree().create_timer(0.05).timeout 
	for child in levels_node.get_children():
			child.transform.basis = Basis(Vector3(1, 0, 0), PI) * child.transform.basis
	for i in range(10,1,-1):	
		pixelshader.set_shader_parameter("quantize_size",i)
		await get_tree().create_timer(0.05).timeout 


func initialize_card_pool():
	cards.clear()
	card_info.clear()
	
	# 添加负面卡片
	for i in range(NEGATIVE_CARDS):
		var card_data = { "type": CardType.NEGATIVE, "id": i + 1, "is_drawn": false }
		cards.append(card_data)
		card_info[i + 1] = card_data
	
	# 添加普通正面卡片
	for i in range(POSITIVE_CARDS):
		var card_data = { "type": CardType.POSITIVE, "id": NEGATIVE_CARDS + i + 1, "is_drawn": false }
		cards.append(card_data)
		card_info[NEGATIVE_CARDS + i + 1] = card_data
	
	# 添加特别强化卡
	for i in range(POSITIVE_SPECIAL_CARDS):
		var card_data = { "type": CardType.POSITIVE_SPECIAL, "id": NEGATIVE_CARDS + POSITIVE_CARDS + i + 1, "is_drawn": false }
		cards.append(card_data)
		card_info[NEGATIVE_CARDS + POSITIVE_CARDS + i + 1] = card_data

func draw_card() -> int:
	var rand = randf()
	
	if rand < positive_weight:
		return draw_positive_card()
	else:
		return draw_negative_card()

func draw_positive_card() -> int:
	var special_cards = []
	var normal_cards = []
	
	# 将正面强化卡和普通正面卡分类
	for card in cards:
		if card["type"] == CardType.POSITIVE_SPECIAL and not card["is_drawn"]:
			special_cards.append(card)
		elif card["type"] == CardType.POSITIVE and not card["is_drawn"]:
			normal_cards.append(card)
	
	var rand = randf()
	if rand < special_weight and special_cards.size() > 0:
		# 从特殊卡组中随机选取一张
		var card = special_cards[int(randf_range(0, special_cards.size()))]
		card["is_drawn"] = true
		return card["id"]
	elif normal_cards.size() > 0:
		# 从普通正面卡组中随机选取一张
		var card = normal_cards[int(randf_range(0, normal_cards.size()))]
		card["is_drawn"] = true
		return card["id"]
	
	return -1  # 如果没有卡片可选，返回-1

func draw_negative_card() -> int:
	var negative_cards = []
	
	# 收集所有的负面卡片
	for card in cards:
		if card["type"] == CardType.NEGATIVE and not card["is_drawn"]:
			negative_cards.append(card)
	
	if negative_cards.size() > 0:
		# 从负面卡组中随机选取一张
		var card = negative_cards[int(randf_range(0, negative_cards.size()))]
		card["is_drawn"] = true
		return card["id"]
	
	return -1  # 如果没有卡片可选，返回-1

func set_positive_weight():
	if positive_weight == 0.5:
		positive_weight = 0.75
	elif positive_weight == 0.75:
		positive_weight = 0.25
	elif positive_weight == 0.25:
		positive_weight = 0.5
	special_weight = 1.0 - positive_weight
	positive_weight_bar.value = positive_weight * 100
	special_weight_bar.value = special_weight * 100

func get_card_info(card_id: int) -> Dictionary:
	if card_info.has(card_id):
		return card_info[card_id]
	return {}


func _on_player_weight_change_ordered() -> void:
	set_positive_weight()


func _on_player_game_over() -> void:
	Global.RESET_BY_GAME_OVER += 1
	call_deferred("_reload_scene")

func _reload_scene() -> void:
	get_tree().reload_current_scene()

func _on_enemy_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	var enemy_spawn_location = get_node("SpawnPath/PathFollow3D")
	enemy_spawn_location.progress_ratio = randf()
	var player_position = $Player.position
	enemy.spawn_and_chase()
	get_node("Enemies").add_child(enemy)
