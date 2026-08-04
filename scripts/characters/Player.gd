extends CharacterBody2D
class_name Player

@export var speed: float = 300.0
@export var jump_velocity: float = -500.0
@export var acceleration: float = 2000.0
@export var friction: float = 1500.0

@export_group("Platformer Polish")
@export var coyote_time: float = 0.15
@export var jump_buffer_time: float = 0.15

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_active: bool = true:
	set(value):
		is_active = value
		queue_redraw()

func _ready() -> void:
	# Architecture: Set Player to Layer 2 (bit value 2).
	collision_layer = 2
	# Ensure Player collides with World (Layer 1) and Shadows (Layer 3/value 4)
	# It explicitly ignores the Drone (Layer 4/value 8)
	collision_mask = 1 | 4

func _physics_process(delta: float) -> void:
	# Update polish timers
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer -= delta
		
	if is_active and Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer -= delta

	# Apply gravity safely
	if not is_on_floor():
		velocity.y += gravity * delta

	if not is_active:
		if is_on_floor():
			_apply_friction(delta)
		move_and_slide()
		return

	# Handle Jump gracefully using buffers
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		_jump_buffer_timer = 0.0 # Consume jump buffer
		_coyote_timer = 0.0      # Consume coyote time

	# Get input direction gracefully with acceleration/deceleration
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		_apply_friction(delta)

	move_and_slide()
	
	# Push RigidBody2D objects
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is RigidBody2D:
			# Apply a solid horizontal push based on normal
			var push_force = 1500.0
			collider.apply_central_impulse(Vector2(-collision.get_normal().x, 0) * push_force * delta)

func _apply_friction(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, friction * delta)

func _draw() -> void:
	var rect := Rect2(-16, -32, 32, 64)
	draw_rect(rect, Color.DODGER_BLUE if is_active else Color.SLATE_GRAY)
