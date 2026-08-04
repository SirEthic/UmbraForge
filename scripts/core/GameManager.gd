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
	# Programmatic input injection avoids modifying project.godot blindly
	var actions = {
		"move_left": KEY_A,
		"move_right": KEY_D,
		"move_up": KEY_W,
		"move_down": KEY_S,
		"jump": KEY_SPACE,
		"switch_char": KEY_TAB,
		"quit": KEY_ESCAPE
	}
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		else:
			InputMap.action_erase_events(action)
		
		var event = InputEventKey.new()
		event.physical_keycode = actions[action]
		InputMap.action_add_event(action, event)
		
		# Adding arrow key alternates cleanly
		if action == "move_left":
			var ev2 = InputEventKey.new(); ev2.physical_keycode = KEY_LEFT; InputMap.action_add_event(action, ev2)
		if action == "move_right":
			var ev2 = InputEventKey.new(); ev2.physical_keycode = KEY_RIGHT; InputMap.action_add_event(action, ev2)
		if action == "move_up":
			var ev2 = InputEventKey.new(); ev2.physical_keycode = KEY_UP; InputMap.action_add_event(action, ev2)
		if action == "move_down":
			var ev2 = InputEventKey.new(); ev2.physical_keycode = KEY_DOWN; InputMap.action_add_event(action, ev2)

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
