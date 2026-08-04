extends CharacterBody2D
class_name Drone

@export var speed: float = 400.0
@export var acceleration: float = 3000.0
@export var friction: float = 2500.0

var is_active: bool = false

func _ready() -> void:
	# Ensure Drone does NOT collide with Shadows (Layer 3) to prevent feedback loops
	collision_mask &= ~4

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

func _process(_delta: float) -> void:
	queue_redraw()
