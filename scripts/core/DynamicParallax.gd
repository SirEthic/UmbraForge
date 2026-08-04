extends ParallaxBackground

@onready var parallax_layer = $ParallaxLayer
@onready var sprite = $ParallaxLayer/Sprite2D

func _ready():
	get_tree().root.size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()

func _on_viewport_size_changed():
	var viewport_size = get_viewport().get_visible_rect().size
	var texture_size = sprite.texture.get_size()
	
	# Calculate the scale needed to fill the screen vertically
	# We multiply by a factor to give it extra vertical slack for the parallax movement
	var target_scale_y = (viewport_size.y * 2.0) / texture_size.y
	
	# Apply scale (keeping it uniform so the image doesn't stretch weirdly)
	sprite.scale = Vector2(target_scale_y, target_scale_y)
	
	# Center the sprite so it covers the top and bottom equally
	var scaled_size = texture_size * target_scale_y
	
	# Position it so it covers enough space above and below the screen
	sprite.position = Vector2(0, -scaled_size.y / 4.0)
	
	# Update mirroring to match the exact scaled width so it loops perfectly horizontally
	parallax_layer.motion_mirroring = Vector2(scaled_size.x, 0)
