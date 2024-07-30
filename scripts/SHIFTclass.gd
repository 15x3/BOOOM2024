extends Node3D
# 定义一个新的类
class SHIFT:
	# 类的属性
	var grav_constract := 15

	# 构造函数
	func _init() -> void:
		grav_constract = -grav_constract
