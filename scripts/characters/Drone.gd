extends CharacterBody2D
class_name Drone

@export var smooth_speed: float = 15.0

var player: Node2D
var _is_dragging: bool = false
var _pulse_time: float = 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	player = get_tree().current_scene.find_child("Player")

func _process(delta: float) -> void:
	_pulse_time += delta
	_is_dragging = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	if _is_dragging:
		global_position = global_position.lerp(get_global_mouse_position(), 1.0 - exp(-smooth_speed * delta))
		
	# Instant recall mechanic: Retrieve the Drone instantly without dragging it across the screen!
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if is_instance_valid(player):
			global_position = player.global_position + Vector2(0, -50)
			
	# Request visual redraw every frame for the tether and animations
	queue_redraw()

func _draw() -> void:
	# 1. Draw a faint magical tether connecting the Drone to the Player
	if is_instance_valid(player):
		var local_player_pos = to_local(player.global_position)
		draw_line(Vector2.ZERO, local_player_pos, Color(1.5, 1.2, 0.8, 0.2), 2.0)
		
	# 2. Visual State Feedback
	# If dragging, glow bright white-gold. If locked, warm gold with a gentle pulse.
	var core_color = Color(2.0, 1.8, 1.2, 1.0) if _is_dragging else Color(1.5, 1.2, 0.8, 1.0)
	var core_radius = 8.0 + (2.0 * sin(_pulse_time * 5.0) if not _is_dragging else 0.0)
	
	draw_circle(Vector2.ZERO, core_radius, core_color)
