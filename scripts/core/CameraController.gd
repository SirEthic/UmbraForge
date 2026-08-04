extends Camera2D
class_name CameraController

@export var player: Node2D
@export var drone: Node2D

@export var smooth_speed: float = 8.0
@export var look_ahead: float = 100.0

func _physics_process(delta: float) -> void:
	var target_pos := global_position
	
	if player and player.get("is_active"):
		target_pos = player.global_position
		# Slight look-ahead based on player velocity for better platforming vision
		if player is CharacterBody2D:
			target_pos.x += sign(player.velocity.x) * look_ahead * min(abs(player.velocity.x) / 300.0, 1.0)
			
	elif drone and drone.get("is_active"):
		target_pos = drone.global_position
		
	# Smoothly interpolate to the active character
	global_position = global_position.lerp(target_pos, smooth_speed * delta)
