extends Area2D
class_name KillVolume

@export var respawn_point: Node2D

func _ready() -> void:
	# Ensure the Area2D only detects relevant bodies (Player and Crates)
	collision_layer = 0
	collision_mask = 2 | 1 # Player is Layer 2, Crate is Layer 1
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# Safely respawn the player and kill momentum
		if respawn_point:
			body.global_position = respawn_point.global_position
			body.velocity = Vector2.ZERO
	elif body is RigidBody2D:
		# Delete physics objects that fall into the void to prevent memory leaks
		body.queue_free()
