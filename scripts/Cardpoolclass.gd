extends Node

class_name CardPool

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
var positive_weight = 0.7 # 抽中正面卡的权重
var special_weight = 1.0 - positive_weight # 抽中正面卡时抽中强化卡的权重

# 初始化卡池
var cards: Array = []
var card_info: Dictionary = {}

func _init():
	initialize_card_pool()

func initialize_card_pool():
	cards.clear()
	card_info.clear()
	
	# 添加负面卡片
	for i in range(NEGATIVE_CARDS):
		var card_data = { "type": CardType.NEGATIVE, "id": i + 1 }
		cards.append(card_data)
		card_info[i + 1] = card_data
	
	# 添加普通正面卡片
	for i in range(POSITIVE_CARDS):
		var card_data = { "type": CardType.POSITIVE, "id": NEGATIVE_CARDS + i + 1 }
		cards.append(card_data)
		card_info[NEGATIVE_CARDS + i + 1] = card_data
	
	# 添加特别强化卡
	for i in range(POSITIVE_SPECIAL_CARDS):
		var card_data = { "type": CardType.POSITIVE_SPECIAL, "id": NEGATIVE_CARDS + POSITIVE_CARDS + i + 1 }
		cards.append(card_data)
		card_info[NEGATIVE_CARDS + POSITIVE_CARDS + i + 1] = card_data

func draw_card() -> int:
	var rand = randf()
	
	if rand < positive_weight:
		return draw_positive_card()
	else:
		return draw_negative_card()

func draw_positive_card() -> int:
	var rand = randf()
	if rand < special_weight:
		for card in cards:
			if card["type"] == CardType.POSITIVE_SPECIAL:
				#cards.erase(card) #删除卡池中卡片
				return card["id"]
	else:
		for card in cards:
			if card["type"] == CardType.POSITIVE:
				#cards.erase(card) #删除卡池中卡片
				return card["id"]
	return -1

func draw_negative_card() -> int:
	for card in cards:
		if card["type"] == CardType.NEGATIVE:
			#cards.erase(card) #删除卡池中卡片
			return card["id"]
	return -1

func set_positive_weight(weight: float):
	positive_weight = clamp(weight, 0.0, 1.0)
	special_weight = 1.0 - positive_weight

func get_card_info(card_id: int) -> Dictionary:
	if card_info.has(card_id):
		return card_info[card_id]
	return {}
