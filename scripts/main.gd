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
const PLAYER_START_POS : Vector3 = Vector3(0,2,37.841)

#var enemy_left = 4
# 概率控制变量
var positive_weight = 100 # 不再使用，改为全局变量
var special_weight = 100 # 不再使用，改为全局变量
@onready var positive_weight_bar = $HUD/CardPositiveWeightBar
@onready var special_weight_bar = $HUD/CardSpecialWeightBar
@onready var pixelshader : ShaderMaterial = preload("res://shaders/pixel_shader.tres")
@export var enemy_scene : PackedScene
@export var bubble : PackedScene

var text_array = ["×","⚡","♥"]

# 初始化卡池
var cards: Array = []
var card_info: Dictionary = {}

# 假设 Levels 节点和 Enemies 节点为当前场景的子节点
var levels_node: Node
var enemies_node: Node
var cardpool = CardPool

#var current_wave = 1 # 不再使用

signal enemy_spawn_ordered
signal random_rooled
signal boss_fight_ordered

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Trigger_area_miami.position = Vector3(-155,30,0)
	#print(Global.DEATH_TIMES)
	levels_node = get_node("Level")
	enemies_node = get_node("Enemies")
	initialize_card_pool()
	$Player.global_position = PLAYER_START_POS
	Global.TUTORIAL = false
	Global.IS_IT_GAME_STARTED = false
	$AnimationPlayer.play("new_animation")
	await get_tree().create_timer(1).timeout 
	Global.IS_IT_GAME_STARTED = true
	# RE - 重启时的四次选择
	if Global.RESET_BY_GAME_OVER >= 1:
		pass
	if Global.RESET_BY_GAME_OVER >= 2:
		pass
	if Global.RESET_BY_GAME_OVER >= 3:
		pass
	if Global.RESET_BY_GAME_OVER >= 4:
		pass

func _process(delta: float) -> void:
	weight_calculate()
	
func _on_player_death_reloaded() -> void:
	Global.DEATH_TIMES += 1 
	$HUD/Death/Label.visible = true
	Engine.time_scale = 0.1
	await get_tree().create_timer(4).timeout
	$PathBoss/PathFollow3D.progress_ratio = randf()
	$Player.position = $PathBoss/PathFollow3D.position
	$HUD/Death/Label.visible = false
	Engine.time_scale = 1.0
	$Player.health = 100
	$HUD/Health.text = "♥ 100% [==========]"
	$Player.power = 100
	$HUD/Skillbar.text = "⚡  60% [==========]"
	#get_tree().reload_current_scene()
	
#func _on_player_scene_filp_ordered() -> void:
	#flip_levels()

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

#func flip_levels():
	## 遍历 Levels 节点下的所有 GridMap 子节点
	#for i in range(1,10):
		#pixelshader.set_shader_parameter("quantize_size",i)
		#await get_tree().create_timer(0.05).timeout 
	#for child in levels_node.get_children():
			#child.transform.basis = Basis(Vector3(1, 0, 0), PI) * child.transform.basis
	#for i in range(10,1,-1):	
		#pixelshader.set_shader_parameter("quantize_size",i)
		#await get_tree().create_timer(0.05).timeout 


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

func spawn_enemies(num) -> void:
	for i in num:
		var enemy = enemy_scene.instantiate()
		var enemy_spawn_location = get_node("SpawnPath/PathFollow3D")
		enemy_spawn_location.progress_ratio = randf()
		var player_position = $Player.position
		enemy.global_transform.origin = enemy_spawn_location.position
		get_node("Enemies").add_child(enemy)
		#enemy_spawned.connect($HUD._on_enemy_spawn_or_destroyed.bind(1))
		#get_tree().create_timer(0.05).timeout

func _on_hud_wave_cleared() -> void:
	Global.WAVES += 1
	if !Global.IS_BOSS_FIGHT:
		$HUD/WaveLabel.text = "第 "+str(Global.WAVES)+" / 10 波次"
		$HUD/WaveLabel.visible = true
		await get_tree().create_timer(5).timeout 
		$HUD/WaveLabel.visible = false
	#enemy_spawn_ordered.emit(5)
	if Global.WAVES == 1: # 第二波，SHIFT机制引入
		enemy_spawn_ordered.emit(5)
		Global.IS_SHIFT_TRIGGERED = true
		set_hint("单击[E]改变前方物体/敌人的重力")
		await get_tree().create_timer(5).timeout
		set_hint("快速双击[E]改变自身重力")
		await get_tree().create_timer(5).timeout
		set_hint("注意：高于建筑时会受到环境伤害")
		await get_tree().create_timer(5).timeout
		$HUD/Hint2.visible = false
		$HUD/Skillbar.visible = true
		var bubble_instantiate = bubble.instantiate()
		bubble_instantiate.position = Vector3(0,20,0)
		bubble_instantiate.scale = Vector3(0.001,0.001,0.001)
		bubble_instantiate.bubble_type = bubble_instantiate.BubbleType.RANDOM
		add_child(bubble_instantiate)
		var bubble_tween = bubble_instantiate.create_tween()
		bubble_tween.tween_property(bubble_instantiate,"scale",Vector3(1,1,1),5)
	elif Global.WAVES == 2: 
		#Global.IS_BOSS_FIGHT = true
		#print("boss")
		# 测试脚本
		#Global.IS_BOSS_TRIGGER_READY = true
		#emit_signal("boss_fight_ordered")
		# 另一个测试
		enemy_spawn_ordered.emit(6)
		Global.IS_MIAMI_TRIGGERED = true
		$Trigger_area_miami.create_tween().tween_property($Trigger_area_miami,"position",Vector3(-15,30,15),5)
		await get_tree().create_timer(5).timeout
		$AnimationPlayer.play("new_animation_2")
	elif Global.WAVES == 3: 
		enemy_spawn_ordered.emit(10)
		set_hint("每击杀3个敌人可触发一次自动摇奖")
		await get_tree().create_timer(5).timeout
		set_hint("具体奖励/击杀计数在右上方显示")
		await get_tree().create_timer(5).timeout
		set_hint("进入中央绿色泡泡内可改变概率")
		await get_tree().create_timer(5).timeout
	elif Global.WAVES == 4: # 不公平随机性介绍/场景切换介绍
		enemy_spawn_ordered.emit(10)
		#var bubble_instantiate = bubble.instantiate()
		#bubble_instantiate.position = Vector3(0,20,0)
		#bubble_instantiate.bubble_type = bubble_instantiate.BubbleType.RE
		#add_child(bubble_instantiate)
		set_hint("进入红色球将开启狂暴模式")
		#$HUD/Hint2.visible = false
		#$HUD/Hint2.text = "可以通过进入场地中央的黑洞在游戏主题间切换"
		#$HUD/Hint2.visible = true
		await get_tree().create_timer(5).timeout
		set_hint("持续时间由⚡剩余值决定")
		#$HUD/Hint2.visible = false
		#$HUD/Hint2.text = "不同主题下，击杀怪物/场景交互的核心机制将有所不同"
		#$HUD/Hint2.visible = true
		await get_tree().create_timer(5).timeout
		$HUD/Hint2.visible = false
	elif Global.WAVES >= 5 and Global.WAVES != 10:
		enemy_spawn_ordered.emit(Global.WAVES * 2)
	elif Global.WAVES == 10: # BOSS COMING UP
		$AudioStream_Clean.stop()
		$AudioStream_Nasty.stop()
		Global.IS_BOSS_TRIGGER_READY = true
		emit_signal("boss_fight_ordered")
		pass 
	elif Global.WAVES >= 11:
		if Global.IS_BOSS_FIGHT:
			enemy_spawn_ordered.emit(10)


func set_hint(word:String):
		$HUD/Hint2.visible = false
		$HUD/Hint2.text = word
		$HUD/Hint2.visible = true

func weight_calculate():
	Global.POSITIVE_WEIGHT -= 0.002
	#print(Global.POSITIVE_WEIGHT)
	Global.SPECIAL_WEIGHT -= 0.002
	var positive_weight_cal = Global.POSITIVE_WEIGHT / 200
	var special_weight_cal = Global.SPECIAL_WEIGHT / 200
	var negative_weight_cal = 1 - positive_weight_cal - special_weight_cal

func random_rool():
	var draw = randi_range(1,200)
	var special_weight_max_range = Global.POSITIVE_WEIGHT + Global.SPECIAL_WEIGHT
	if draw <= Global.POSITIVE_WEIGHT:
		return "health"
	elif draw > Global.POSITIVE_WEIGHT and draw <= special_weight_max_range:
		return "power"
	else: 
		return "none"


func _on_hud_kill_count_reached() -> void:
	for i in range(1,8):
		var mod = i % 3
		$HUD/Random/Label.clear()
		$HUD/Random/Label.append_text("[shake rate=32 level=15][font size=40][right]|-" + text_array[i % 3] + "-|[/right][/font][/shake]")
		await get_tree().create_timer(0.1).timeout 
	var result = random_rool()
	random_rooled.emit(result)
