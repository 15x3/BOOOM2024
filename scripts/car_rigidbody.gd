extends RigidBody3D
signal gravity_change_ordered

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_gravity_change_ordered() -> void:
		gravity_scale = -0.2
		apply_central_force(Vector3.UP * 100)
		await get_tree().create_timer(5).timeout
		gravity_scale = 1.0
		apply_central_impulse(Vector3.ZERO)
