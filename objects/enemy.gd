extends Node3D

@export var player: Node3D

@onready var raycast = $RayCast
@onready var muzzle_a = $MuzzleA
@onready var muzzle_b = $MuzzleB

var health := 100
var time := 0.0
var target_position: Vector3
var destroyed := false
var min_speed = 10
var max_speed = 50

signal spawn_or_destroyed

# When ready, save the initial position


func _ready():
	target_position = position
	if Global.IS_IT_MIAMI:
		health = 1
		print("OH! MIAMI TIME!")
	else: 
		health = health * (10 - Global.DEATH_TIMES) / 10 #RE - 怪物血量跟随减少
	emit_signal("spawn_or_destroyed")

func _process(delta):
	self.look_at(player.position + Vector3(0, 0.5, 0), Vector3.UP, true)  # Look at player
	target_position.y += (cos(time * 5) * 1) * delta  # Sine movement (up and down)

	time += delta

	position = target_position


# Take damage from player


func damage(amount):
	Audio.play("sounds/enemy_hurt.ogg")

	health -= amount

	if health <= 0 and !destroyed:
		destroy()


# Destroy the enemy when out of health


func destroy():
	Audio.play("sounds/enemy_destroy.ogg")

	destroyed = true
	emit_signal("spawn_or_destroyed")
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

			collider.damage(5)  # Apply damage to player
			
func spawn_and_chase(start_position, player_position):
	# We position the mob by placing it at start_position
	# and rotate it towards player_position, so it looks at the player.
	look_at_from_position(start_position, player_position, Vector3.UP)
	# Rotate this mob randomly within range of -45 and +45 degrees,
	# so that it doesn't move directly towards the player.
	rotate_y(randf_range(-PI / 4, PI / 4))

	# We calculate a random speed (integer)
	var random_speed = randi_range(min_speed, max_speed)
	# We calculate a forward velocity that represents the speed.
	velocity = Vector3.FORWARD * random_speed
	# We then rotate the velocity vector based on the mob's Y rotation
	# in order to move in the direction the mob is looking.
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	pass
