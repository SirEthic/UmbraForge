extends Area2D

var _triggered := false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Explicitly detect the Player (Layer 2)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	if body.name == "Player":
		_triggered = true
		print("YOU WIN! Level Complete!")
		
		# Robust UI spawning logic
		var canvas = CanvasLayer.new()
		canvas.layer = 100 # Ensure it draws over everything
		
		var color_rect = ColorRect.new()
		color_rect.color = Color(0, 0, 0, 0.8) # Darken screen
		color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		var label = Label.new()
		label.text = "LEVEL COMPLETE!"
		label.add_theme_font_size_override("font_size", 96)
		label.add_theme_color_override("font_color", Color(1.5, 1.2, 0.8, 1.0)) # HDR Gold
		label.set_anchors_preset(Control.PRESET_CENTER)
		
		canvas.add_child(color_rect)
		color_rect.add_child(label)
		
		get_tree().current_scene.add_child(canvas)
		
		# Pause the game so the player doesn't fall off while admiring the win screen
		get_tree().paused = true
		
		# Wait 3 seconds (ignoring pause) and return to the Hub
		await get_tree().create_timer(3.0, true, false, true).timeout
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/levels/hub.tscn")
