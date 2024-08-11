extends Node3D

@export var player: Node3D
@export var character_speed := 4

@onready var raycast = $RayCast
@onready var muzzle_a = $MuzzleA
@onready var muzzle_b = $MuzzleB
@onready var navigation_agent = $NavigationAgent3D as NavigationAgent3D
@onready var health := 100
var time := 0.0
var target_position: Vector3
var destroyed := false
var min_speed = 10
var max_speed = 50
var is_floating = false

signal spawn_or_destroyed
signal gravity_change_ordered
# When ready, save the initial position



func _ready():
	player = $"../../Player"
	target_position = position
	#if Global.IS_IT_MIAMI:
		#health = 1
		#print("OH! MIAMI TIME!")
	#else: 
		#health = health * (10 - Global.DEATH_TIMES) / 10 #RE - 怪物血量跟随减少
	spawn_or_destroyed.connect($"../../HUD"._on_enemy_spawn_or_destroyed.bind(-1))

func _process(delta):
	# Look at player
	var velocity = Vector3.ZERO
	self.look_at(player.position + Vector3(0, 0.5, 0), Vector3.UP, true)

	# Sine movement (up and down)
	target_position.y += (cos(time * 5) * 1) * delta
	time += delta
	# Update target position for NavigationAgent3D
	if is_floating:
		navigation_agent.set_target_position(self.position)
		get_tree().create_tween().tween_property(self,"position",self.position + Vector3(0,5,0),5)
	else:
		navigation_agent.set_target_position(player.position)

	# Move towards target using NavigationAgent3D
	#var direction = (navigation_agent.get_next_path_position() - global_transform.origin).normalized()
	#velocity = direction * min_speed * delta
	#translate(velocity)
#
	#position = target_position

# Take damage from player


func damage(amount):
	Audio.play("sounds/enemy_hurt.ogg")

	health -= amount

	if health <= 0 and !destroyed:
		destroy()

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return
	var next_position := navigation_agent.get_next_path_position()
	var offset := next_position - global_position
	global_position = global_position.move_toward(next_position, delta * character_speed)
	

# Destroy the enemy when out of health


func destroy():
	Audio.play("sounds/enemy_destroy.ogg")
	
	if Global.IS_IN_RANDOM:
		if Global.RANDOM_SPECIAL_SELECTED:
			pass
		else:
			pass
	destroyed = true
	emit_signal("spawn_or_destroyed")
	#spawn_or_destroyed.emit(1)
	queue_free()
	


# Shoot when timer hits 0


func _on_timer_timeout():
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var collider = raycast.get_collider()

		if collider.has_method("damage"):  # Raycast collides with player
			# Play muzzle flash animation(s)

			muzzle_a.frame = 0
			muzzle_a.play("default")
			muzzle_a.rotation_degrees.z = randf_range(-45, 45)

			muzzle_b.frame = 0
			muzzle_b.play("default")
			muzzle_b.rotation_degrees.z = randf_range(-45, 45)

			Audio.play("sounds/enemy_attack.ogg")

			collider.damage(1)  # Apply damage to player
			
#func spawn_and_chase(start_position, player_position):
	## We position the mob by placing it at start_position
	## and rotate it towards player_position, so it looks at the player.
	#look_at_from_position(start_position, player_position, Vector3.UP)
	## Rotate this mob randomly within range of -45 and +45 degrees,
	## so that it doesn't move directly towards the player.
	#rotate_y(randf_range(-PI / 4, PI / 4))
#
	## We calculate a random speed (integer)
	#var random_speed = randi_range(min_speed, max_speed)
	## We calculate a forward velocity that represents the speed.
	#velocity = Vector3.FORWARD * random_speed
	## We then rotate the velocity vector based on the mob's Y rotation
	## in order to move in the direction the mob is looking.
	#velocity = velocity.rotated(Vector3.UP, rotation.y)
	#pass

func _on_gravity_change_ordered() -> void:
	is_floating = true
	await get_tree().create_timer(5).timeout
	is_floating = false
