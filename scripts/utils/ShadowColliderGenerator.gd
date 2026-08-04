extends Node2D
class_name ShadowColliderGenerator

@export var light_source: PointLight2D
@export var occluders_parent: Node2D
@export var shadow_length: float = 2000.0

var shadow_body: AnimatableBody2D
var _generated_colliders: Array[CollisionPolygon2D] = []

var _last_light_pos: Vector2
var _last_occluder_transforms: Array[Transform2D] = []

func _ready() -> void:
	shadow_body = AnimatableBody2D.new()
	shadow_body.sync_to_physics = true
	
	# Architecture: Place shadows exclusively on Collision Layer 3 (bit value 4).
	# This prevents the Drone from colliding with its own shadow.
	shadow_body.collision_layer = 4
	shadow_body.collision_mask = 0
	add_child(shadow_body)

func _physics_process(_delta: float) -> void:
	if not light_source or not occluders_parent:
		return
		
	# Performance: Only regenerate geometry if the light or occluders have actually moved.
	var needs_update := false
	var light_pos := light_source.global_position
	
	if not light_pos.is_equal_approx(_last_light_pos):
		needs_update = true
		_last_light_pos = light_pos
		
	var current_transforms: Array[Transform2D] = []
	var children := occluders_parent.get_children()
	for i in range(children.size()):
		var node := children[i] as Node2D
		if node is LightOccluder2D:
			current_transforms.append(node.global_transform)
			
	if current_transforms.size() != _last_occluder_transforms.size():
		needs_update = true
	else:
		for i in range(current_transforms.size()):
			if current_transforms[i] != _last_occluder_transforms[i]:
				needs_update = true
				break
				
	if needs_update:
		_last_occluder_transforms = current_transforms
		_generate_shadow_colliders(light_pos)

func _generate_shadow_colliders(light_pos: Vector2) -> void:
	var all_shadow_polys: Array[PackedVector2Array] = []
	
	for occluder_node in occluders_parent.get_children():
		if occluder_node is LightOccluder2D and occluder_node.occluder:
			var poly: PackedVector2Array = occluder_node.occluder.polygon
			
			# Crash prevention: skip invalid/degenerate polygons
			if poly.size() < 3:
				continue
				
			var transform: Transform2D = occluder_node.global_transform
			
			var global_verts: Array[Vector2] = []
			for i in range(poly.size()):
				global_verts.append(transform * poly[i])
				
			var is_clockwise := Geometry2D.is_polygon_clockwise(global_verts)
			all_shadow_polys.append(PackedVector2Array(global_verts))
			
			var count := global_verts.size()
			for i in range(count):
				var a := global_verts[i]
				var b := global_verts[(i + 1) % count]
				
				var mid := (a + b) * 0.5
				var edge_dir := (b - a).normalized()
				var normal := Vector2(-edge_dir.y, edge_dir.x) if is_clockwise else Vector2(edge_dir.y, -edge_dir.x)
				
				var light_dir := (mid - light_pos).normalized()
				
				if normal.dot(light_dir) < 0.0:
					var dir_a := (a - light_pos).normalized()
					var dir_b := (b - light_pos).normalized()
					
					var proj_a := a + dir_a * shadow_length
					var proj_b := b + dir_b * shadow_length
					
					var quad := PackedVector2Array([b, a, proj_a, proj_b]) if is_clockwise else PackedVector2Array([a, b, proj_b, proj_a])
					all_shadow_polys.append(quad)

	while _generated_colliders.size() < all_shadow_polys.size():
		var col := CollisionPolygon2D.new()
		shadow_body.add_child(col)
		_generated_colliders.append(col)
		
	for i in range(all_shadow_polys.size(), _generated_colliders.size()):
		_generated_colliders[i].set_deferred("disabled", true)
		
	for i in range(all_shadow_polys.size()):
		var col: CollisionPolygon2D = _generated_colliders[i]
		
		var local_poly := PackedVector2Array()
		for pt in all_shadow_polys[i]:
			local_poly.append(shadow_body.global_transform.affine_inverse() * pt)
			
		col.polygon = local_poly
		col.set_deferred("disabled", false)
