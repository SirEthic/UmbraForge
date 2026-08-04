extends RigidBody2D
class_name Crate

var initial_position: Vector2

func _ready() -> void:
	initial_position = global_position

func respawn() -> void:
	global_position = initial_position
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
