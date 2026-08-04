extends Node2D

@export var shadow_generator: ShadowColliderGenerator

func _ready() -> void:
	if shadow_generator and not shadow_generator.occluders_parent:
		# Attempt to find the main Occluders node in the current scene
		var occluders = get_tree().current_scene.find_child("Occluders", true, false)
		if occluders:
			shadow_generator.occluders_parent = occluders
