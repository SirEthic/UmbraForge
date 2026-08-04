extends Area2D

@export_file("*.tscn") var target_level: String

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Detect Player
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and target_level != "":
		# Transition to the next scene!
		call_deferred("_change_scene")

func _change_scene() -> void:
	get_tree().change_scene_to_file(target_level)
