extends CharacterBody2D
class_name Drone

@export var speed: float = 400.0
@export var acceleration: float = 3000.0
@export var friction: float = 2500.0

var is_active: bool = false:
	set(value):
		is_active = value
		queue_redraw()

func _ready() -> void:
	# Architecture: Set Drone to Layer 4 (bit value 8).
	collision_layer = 8
	# Ensure Drone ONLY collides with the World (Layer 1).
	# It explicitly ignores the Player (Layer 2) and Shadows (Layer 3).
	collision_mask = 1

func _physics_process(delta: float) -> void:
	if not is_active:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		move_and_slide()
		return

	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 12, Color.GOLD if is_active else Color.DIM_GRAY)
