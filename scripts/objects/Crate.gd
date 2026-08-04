extends RigidBody2D
class_name Crate

var initial_position: Vector2

func _ready() -> void:
	initial_position = global_position

func respawn() -> void:
	set_deferred("global_position", initial_position)
	set_deferred("linear_velocity", Vector2.ZERO)
	set_deferred("angular_velocity", 0.0)
