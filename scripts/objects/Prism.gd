extends RigidBody2D
class_name Prism

@export var max_range: float = 800.0
@export var drone: Node2D
@export var shadow_generator: ShadowColliderGenerator

@onready var light: PointLight2D = $PointLight2D

var initial_position: Vector2

func _ready() -> void:
	initial_position = global_position
	light.enabled = false
	if shadow_generator and not shadow_generator.occluders_parent:
		shadow_generator.occluders_parent = get_parent()

func respawn() -> void:
	set_deferred("global_position", initial_position)
	set_deferred("linear_velocity", Vector2.ZERO)
	set_deferred("angular_velocity", 0.0)

func _physics_process(_delta: float) -> void:
	if not drone:
		return
		
	# Find Drone globally if not set
	var dist := global_position.distance_to(drone.global_position)
	if dist > max_range:
		light.enabled = false
		return
		
	# Check line of sight using Godot's Raycast server
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, drone.global_position)
	query.exclude = [self]
	# Check for World (1). Drone is Layer 8, so it's ignored.
	query.collision_mask = 1
	
	var result = space_state.intersect_ray(query)
	
	if result:
		# Blocked by a crate or wall
		light.enabled = false
	else:
		# Clear line of sight to the Drone!
		light.enabled = true
