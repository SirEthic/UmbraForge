extends Node
class_name GameManager

@export var player: Player
@export var drone: Drone

func _ready() -> void:
	_setup_inputs()
	if player and drone:
		player.is_active = true
		drone.is_active = false

func _setup_inputs() -> void:
	var key_actions = {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"jump": [KEY_SPACE],
		"switch_char": [KEY_TAB],
		"quit": [KEY_ESCAPE]
	}
	var joy_actions = {
		"move_left": [JOY_BUTTON_DPAD_LEFT],
		"move_right": [JOY_BUTTON_DPAD_RIGHT],
		"move_up": [JOY_BUTTON_DPAD_UP],
		"move_down": [JOY_BUTTON_DPAD_DOWN],
		"jump": [JOY_BUTTON_A],
		"switch_char": [JOY_BUTTON_Y],
		"quit": [JOY_BUTTON_BACK]
	}
	var joy_motions = {
		"move_left": {"axis": JOY_AXIS_LEFT_X, "dir": -1.0},
		"move_right": {"axis": JOY_AXIS_LEFT_X, "dir": 1.0},
		"move_up": {"axis": JOY_AXIS_LEFT_Y, "dir": -1.0},
		"move_down": {"axis": JOY_AXIS_LEFT_Y, "dir": 1.0}
	}
	
	for action in key_actions:
		if not InputMap.has_action(action): InputMap.add_action(action)
		else: InputMap.action_erase_events(action)
		
		for keycode in key_actions[action]:
			var event = InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action, event)
			
		for joycode in joy_actions[action]:
			var event = InputEventJoypadButton.new()
			event.button_index = joycode
			InputMap.action_add_event(action, event)
			
		if joy_motions.has(action):
			var event = InputEventJoypadMotion.new()
			event.axis = joy_motions[action].axis
			event.axis_value = joy_motions[action].dir
			InputMap.action_add_event(action, event)

# Unhandled input gracefully manages event triggers natively
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_char"):
		_toggle_active_character()
	elif event.is_action_pressed("quit"):
		get_tree().quit()

func _toggle_active_character() -> void:
	if not player or not drone:
		return
	
	player.is_active = not player.is_active
	drone.is_active = not drone.is_active
