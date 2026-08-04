extends Camera2D
class_name CameraController

@export var player: Node2D
@export var smooth_speed: float = 8.0

func _physics_process(delta: float) -> void:
	if not player:
		return
		
	# Rigidly track the player for stable platforming (removed mouse look-ahead to prevent aiming instability)
	var target_pos = player.global_position
		
	# Smoothly interpolate to the target position
	global_position = global_position.lerp(target_pos, 1.0 - exp(-smooth_speed * delta))
