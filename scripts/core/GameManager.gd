extends Node
class_name GameManager

@export var player: Player
@export var drone: Drone

func _ready() -> void:
	# Show the mouse cursor so you can see where you are dragging the Drone
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_setup_inputs()

func _setup_inputs() -> void:
	var key_actions = {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"jump": [KEY_SPACE],
		"quit": [KEY_ESCAPE]
	}
	
	for action in key_actions:
		if not InputMap.has_action(action): InputMap.add_action(action)
		else: InputMap.action_erase_events(action)
		
		for keycode in key_actions[action]:
			var event = InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action, event)

# Unhandled input gracefully manages event triggers natively
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
