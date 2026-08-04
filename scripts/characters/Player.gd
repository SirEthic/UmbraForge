extends CharacterBody2D
class_name Player

@export var speed: float = 300.0
@export var jump_velocity: float = -500.0
@export var acceleration: float = 2000.0
@export var friction: float = 1500.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_active: bool = true

func _ready() -> void:
	# Ensure Player collides with World (Layer 1) and Shadows (Layer 3)
	collision_mask |= 4

func _physics_process(delta: float) -> void:
	# Apply gravity safely
	if not is_on_floor():
		velocity.y += gravity * delta

	if not is_active:
		_apply_friction(delta)
		move_and_slide()
		return

	# Handle Jump using Godot Input Map
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get input direction gracefully with acceleration/deceleration
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		_apply_friction(delta)

	move_and_slide()

func _apply_friction(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, friction * delta)

func _draw() -> void:
	var rect := Rect2(-16, -32, 32, 64)
	draw_rect(rect, Color.DODGER_BLUE if is_active else Color.SLATE_GRAY)
	
func _process(_delta: float) -> void:
	queue_redraw()
