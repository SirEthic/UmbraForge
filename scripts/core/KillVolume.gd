extends Area2D
class_name KillVolume

@export var respawn_point: Node2D

func _ready() -> void:
	# Ensure the Area2D only detects relevant bodies (Player, Crate, Drone)
	collision_layer = 0
	collision_mask = 1 | 2 | 8 # Crate(1), Player(2), Drone(8)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# Safely respawn the player and kill momentum
		if respawn_point:
			body.global_position = respawn_point.global_position
			body.velocity = Vector2.ZERO
	elif body is Drone:
		# Safely respawn the Drone so the camera doesn't stretch forever
		if respawn_point:
			body.global_position = respawn_point.global_position + Vector2(0, -50)
			body.velocity = Vector2.ZERO
	elif body is RigidBody2D:
		# Respawn critical puzzle pieces, or delete generic physics objects
		if body.has_method("respawn"):
			body.respawn()
		else:
			body.queue_free()
