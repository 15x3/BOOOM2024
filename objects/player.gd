extends CharacterBody3D

# HACK - RE和SHIFT机制本身有一定联动性
@export_subgroup("Properties")
@export var movement_speed = 5
@export var jump_strength = 10

@export_subgroup("Weapons")
@export var weapons: Array[Weapon] = []

const DOUBLE_PRESS_THRESHOLD = 0.2

var weapon: Weapon
var weapon_index := 0

var mouse_sensitivity = 700
var gamepad_sensitivity := 0.075

var mouse_captured := true

var movement_velocity: Vector3
var rotation_target: Vector3

var input_mouse: Vector2

var health:int = 100
var gravity := 0.0
var grav_constract := 15
#SHIFT - 修改参数，增加Grav_constract作为修改重力

var previously_floored := false

var jump_single := true
var jump_double := true

var container_offset = Vector3(1.2, -1.1, -2.75)

var tween:Tween

# kennys包增加变量
var movement_enabled = true
var is_waiting_for_second_press = false
var press_timer = 0.0

signal health_updated
signal death_reloaded
signal scene_filp_ordered
signal cardroll_ordered
signal card_choose_ordered
signal weight_change_ordered
signal game_over

@onready var camera = $Head/Camera
@onready var raycast = $Head/Camera/RayCast
@onready var muzzle = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Muzzle
@onready var container = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Container
@onready var sound_footsteps = $SoundFootsteps
@onready var blaster_cooldown = $Cooldown
@onready var DialogueFinder = $PlayerArea3D
@export var crosshair:TextureRect

@onready var timer_bar = $"../HUD/ProgressBar"
# Functions

func _ready():
	# 初始化 ProgressBar
	timer_bar.visible = false
	timer_bar.min_value = 0
	timer_bar.max_value = DOUBLE_PRESS_THRESHOLD
	timer_bar.value = 0
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	weapon = weapons[weapon_index] # Weapon must never be nil
	initiate_change_weapon(weapon_index)
	if Global.IS_IT_MIAMI:
		# RE - 我还没加上,但是先把判断条件放这里了
		pass

func _physics_process(delta):
	if not movement_enabled: 
		pass
	else:
		# Handle functions
		handle_controls(delta)
		handle_gravity(delta)

		# Movement
		var applied_velocity: Vector3

		movement_velocity = transform.basis * movement_velocity # Move forward

		applied_velocity = velocity.lerp(movement_velocity, delta * 10)
		applied_velocity.y = -gravity

		velocity = applied_velocity
		move_and_slide()

		# Rotation
		camera.rotation.z = lerp_angle(camera.rotation.z, -input_mouse.x * 25 * delta, delta * 5)	

		camera.rotation.x = lerp_angle(camera.rotation.x, rotation_target.x, delta * 25)
		rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)

		container.position = lerp(container.position, container_offset - (applied_velocity / 30), delta * 10)

		# Movement sound
		sound_footsteps.stream_paused = true

		if is_on_floor():
			if abs(velocity.x) > 1 or abs(velocity.z) > 1:
				sound_footsteps.stream_paused = false

		# Landing after jump or falling

		camera.position.y = lerp(camera.position.y, 0.0, delta * 5)

		if is_on_floor() and gravity > 1 and !previously_floored: # Landed
			Audio.play("sounds/land.ogg")
			camera.position.y = -0.1

		previously_floored = is_on_floor()

		# Falling/respawning
		if position.y < -15 or position.y > 15:
			get_tree().reload_current_scene()

# Mouse movement

func _input(event):
	if event is InputEventMouseMotion and mouse_captured:
		
		input_mouse = event.relative / mouse_sensitivity
		
		rotation_target.y -= event.relative.x / mouse_sensitivity
		rotation_target.x -= event.relative.y / mouse_sensitivity
		
	#if Input.is_action_just_pressed("ui_accept"):
		#var dialogue = DialogueFinder.get_overlapping_areas()
		#if dialogue.size() > 0:
			#dialogue[0].action()
			#return

func handle_controls(_delta):
	
	# Mouse capture
	
	if Input.is_action_just_pressed("mouse_capture"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_captured = true
	
	if Input.is_action_just_pressed("mouse_capture_exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_captured = false
		
		input_mouse = Vector2.ZERO
	
	# Movement
	
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	movement_velocity = Vector3(input.x, 0, input.y).normalized() * movement_speed
	
	# Rotation
	
	var rotation_input := Input.get_vector("camera_right", "camera_left", "camera_down", "camera_up")
	
	rotation_target -= Vector3(-rotation_input.y, -rotation_input.x, 0).limit_length(1.0) * gamepad_sensitivity
	rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))
	
	# Shooting
	
	action_shoot()
	
	# Jumping
	
	if Input.is_action_just_pressed("jump"):
		
		if jump_single or jump_double:
			Audio.play("sounds/jump_a.ogg, sounds/jump_b.ogg, sounds/jump_c.ogg")
		
		if jump_double:
			
			gravity = -jump_strength
			jump_double = false
			
		if(jump_single): action_jump()
		
	# Weapon switching
	
	action_weapon_toggle()
	
	# SHIFT - Gravity Change and Scene SHIFT
	if Input.is_action_just_pressed("weapon_toggle"):  # 默认 "ui_select" 映射到 "E" 键
		if is_waiting_for_second_press:
			on_double_press()
		else:
			start_waiting_for_second_press()

	if is_waiting_for_second_press:
		update_press_timer(_delta)

	
	if Input.is_action_just_pressed("shift"):
		Global.IS_IT_MIAMI = not Global.IS_IT_MIAMI
		print("MIAMI TIME TRIGGERED")
		# RE - 目前使用shift来主动触发,但是后续必须改成不能在游戏中主动触发(或者触发有条件)
	# RANDOM - 抽卡动作:
	if Input.is_action_just_pressed("start_cardroll") and Global.IS_RANDOM_TRIGGERED:
		emit_signal("cardroll_ordered")
		print("开始一轮抽卡")
	
	if Input.is_action_just_pressed("choose_card") and Global.IS_RANDOM_TRIGGERED:
		emit_signal("card_choose_ordered")
		print("按下选卡按钮")
		
	if Input.is_action_just_pressed("set_draw_weight") and Global.IS_RANDOM_TRIGGERED:
		emit_signal("weight_change_ordered")
	
# Handle gravity

func handle_gravity(delta):
	
	gravity += grav_constract * delta #SHIFT - 修改重力处理处
	gravity = clamp(gravity, -5, 11) #SHIFT - 控制重力不超过某值
	
	if gravity > 0 and is_on_floor():
		
		jump_single = true
		gravity = 0

# Jumping

func action_jump():
	if grav_constract > 0: #SHIFT - 修改跳跃，增加正反判断
		gravity = -jump_strength
	else:
		pass
	
	jump_single = false;
	jump_double = true;

# Shooting

func action_shoot():
	
	if Input.is_action_pressed("shoot"):
	
		if !blaster_cooldown.is_stopped(): return # Cooldown for shooting
		
		Audio.play(weapon.sound_shoot)
		
		container.position.z += 0.25 # Knockback of weapon visual
		camera.rotation.x += 0.025 # Knockback of camera
		movement_velocity += Vector3(0, 0, weapon.knockback) # Knockback
		
		# Set muzzle flash position, play animation
		
		muzzle.play("default")
		
		muzzle.rotation_degrees.z = randf_range(-45, 45)
		muzzle.scale = Vector3.ONE * randf_range(0.40, 0.75)
		muzzle.position = container.position - weapon.muzzle_position
		
		blaster_cooldown.start(weapon.cooldown)
		
		# Shoot the weapon, amount based on shot count
		
		for n in weapon.shot_count:
		
			raycast.target_position.x = randf_range(-weapon.spread, weapon.spread)
			raycast.target_position.y = randf_range(-weapon.spread, weapon.spread)
			
			raycast.force_raycast_update()
			
			if !raycast.is_colliding(): continue # Don't create impact when raycast didn't hit
			
			var collider = raycast.get_collider()
			
			# Hitting an enemy
			
			if collider.has_method("damage"):
				collider.damage(weapon.damage)
			
			# Creating an impact animation
			
			var impact = preload("res://objects/impact.tscn")
			var impact_instance = impact.instantiate()
			
			impact_instance.play("shot")
			
			get_tree().root.add_child(impact_instance)
			
			impact_instance.position = raycast.get_collision_point() + (raycast.get_collision_normal() / 10)
			impact_instance.look_at(camera.global_transform.origin, Vector3.UP, true) 

# Toggle between available weapons (listed in 'weapons')

func action_weapon_toggle():
	
	if Input.is_action_just_pressed("weapon_toggle"):
		
		weapon_index = wrap(weapon_index + 1, 0, weapons.size())
		initiate_change_weapon(weapon_index)
		
		Audio.play("sounds/weapon_change.ogg")
		
		#grav_constract = -grav_constract

# Initiates the weapon changing animation (tween)

func initiate_change_weapon(index):
	
	weapon_index = index
	
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(container, "position", container_offset - Vector3(0, 1, 0), 0.1)
	tween.tween_callback(change_weapon) # Changes the model

# Switches the weapon model (off-screen)

func change_weapon():
	
	weapon = weapons[weapon_index]

	# Step 1. Remove previous weapon model(s) from container
	
	for n in container.get_children():
		container.remove_child(n)
	
	# Step 2. Place new weapon model in container
	
	var weapon_model = weapon.model.instantiate()
	container.add_child(weapon_model)
	
	weapon_model.position = weapon.position
	weapon_model.rotation_degrees = weapon.rotation
	
	# Step 3. Set model to only render on layer 2 (the weapon camera)
	
	for child in weapon_model.find_children("*", "MeshInstance3D"):
		child.layers = 2
		
	# Set weapon data
	
	raycast.target_position = Vector3(0, 0, -1) * weapon.max_distance
	crosshair.texture = weapon.crosshair

func damage(amount):
	
	health -= amount
	health_updated.emit(health) # Update health on HUD
	
	if health < 0:
		emit_signal("death_reloaded") #RE - 死亡时发出death_reloaded信号，发给Main.gd

# DialogueFinder

#func _unhandled_input(event):
	#if Input.is_action_just_pressed("ui_accept"):
		#var dialogue = DialogueFinder.get_overlapping_areas()
		#if dialogue.size() > 0:
			#dialogue[0].action()
			#return

func on_double_press():
	emit_signal("scene_filp_ordered")
	reset_press_state()

func start_waiting_for_second_press():
	is_waiting_for_second_press = true
	press_timer = 0.0
	timer_bar.visible = true

func update_press_timer(delta):
	press_timer += delta
	timer_bar.value = press_timer
	if press_timer > DOUBLE_PRESS_THRESHOLD:
		on_single_press()

func on_single_press():
	grav_constract = -grav_constract
	reset_press_state()

func reset_press_state():
	is_waiting_for_second_press = false
	press_timer = 0.0
	timer_bar.visible = false


func _on_game_over_area_body_entered(body: Node3D) -> void:
	# 检查进入的物体是否是玩家
	if body.name == "Player":  # 假设玩家节点的名称为 "Player"
		emit_signal("game_over")  # 发出游戏结束信号
		print("Game Over!")  # 你可以在这里调用其他游戏结束逻辑
