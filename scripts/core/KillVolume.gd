extends Area2D
class_name KillVolume

@export var respawn_point: Node2D

func _ready() -> void:
	# Only set default masks if none are configured in editor
	if collision_mask == 1:
		collision_mask = 1 | 2 | 8 # Crate(1), Player(2), Drone(8)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if respawn_point:
			body.set_deferred("global_position", respawn_point.global_position)
			body.set_deferred("velocity", Vector2.ZERO)
	elif body is Drone:
		if respawn_point:
			body.set_deferred("global_position", respawn_point.global_position + Vector2(0, -50))
			body.set_deferred("velocity", Vector2.ZERO)
	elif body.has_method("respawn"):
		# Respawn critical puzzle pieces, or delete generic physics objects
		if body.has_method("respawn"):
			body.respawn()
		else:
			body.queue_free()
