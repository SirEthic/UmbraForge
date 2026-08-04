extends RigidBody2D
class_name Crate

var initial_position: Vector2
var _needs_teleport: bool = false

func _ready() -> void:
	initial_position = global_position

func respawn() -> void:
	_needs_teleport = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _needs_teleport:
		var xform = state.transform
		xform.origin = initial_position
		state.transform = xform
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		_needs_teleport = false
