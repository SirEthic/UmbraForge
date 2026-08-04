extends Node2D
class_name ShadowColliderGenerator

@export var light_source: PointLight2D
@export var occluders_parent: Node2D
@export var shadow_length: float = 2000.0

@export_group("Visuals")
@export var fill_color: Color = Color(0.05, 0.05, 0.08, 1.0)
@export var outline_color: Color = Color(0.6, 0.3, 1.0, 1.0)
@export var outline_width: float = 2.0

var shadow_body: AnimatableBody2D
var _generated_colliders: Array[CollisionPolygon2D] = []
var _generated_visuals_poly: Array[Polygon2D] = []
var _generated_visuals_line: Array[Line2D] = []

var _last_light_pos: Vector2
var _last_occluder_transforms: Array[Transform2D] = []

var _unshaded_material: CanvasItemMaterial

func _ready() -> void:
	# Force shadows to render behind all characters and interactive objects
	z_index = -1
	
	shadow_body = AnimatableBody2D.new()
	shadow_body.sync_to_physics = true
	
	# Architecture: Place shadows exclusively on Collision Layer 3 (bit value 4).
	shadow_body.collision_layer = 4
	shadow_body.collision_mask = 0
	add_child(shadow_body)
	
	# Create a shared material so the physical shadows ignore all 2D lighting
	_unshaded_material = CanvasItemMaterial.new()
	_unshaded_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED

func _physics_process(_delta: float) -> void:
	if not light_source or not occluders_parent:
		return
		
	var needs_update := false
	var light_pos := light_source.global_position
	
	if not light_pos.is_equal_approx(_last_light_pos):
		needs_update = true
		_last_light_pos = light_pos
		
	var current_transforms: Array[Transform2D] = []
	var occluders := _get_all_occluders(occluders_parent)
	for occ in occluders:
		current_transforms.append(occ.global_transform)
			
	if current_transforms.size() != _last_occluder_transforms.size():
		needs_update = true
	else:
		for i in range(current_transforms.size()):
			if current_transforms[i] != _last_occluder_transforms[i]:
				needs_update = true
				break
				
	if needs_update:
		_last_occluder_transforms = current_transforms
		_generate_shadow_colliders(light_pos, occluders)

func _get_all_occluders(node: Node) -> Array[LightOccluder2D]:
	var result: Array[LightOccluder2D] = []
	for child in node.get_children():
		if child is LightOccluder2D:
			result.append(child)
		result.append_array(_get_all_occluders(child))
	return result

func _generate_shadow_colliders(light_pos: Vector2, occluders: Array[LightOccluder2D]) -> void:
	var all_shadow_polys: Array[PackedVector2Array] = []
	
	for occluder_node in occluders:
		if occluder_node.occluder:
			var poly: PackedVector2Array = occluder_node.occluder.polygon
			
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

	# Expand pools if necessary
	while _generated_colliders.size() < all_shadow_polys.size():
		var col := CollisionPolygon2D.new()
		shadow_body.add_child(col)
		_generated_colliders.append(col)
		
		var vis_poly := Polygon2D.new()
		vis_poly.color = fill_color
		vis_poly.material = _unshaded_material
		shadow_body.add_child(vis_poly)
		_generated_visuals_poly.append(vis_poly)
		
		var vis_line := Line2D.new()
		vis_line.default_color = outline_color
		vis_line.width = outline_width
		vis_line.closed = true
		vis_line.joint_mode = Line2D.LINE_JOINT_SHARP
		vis_line.material = _unshaded_material
		shadow_body.add_child(vis_line)
		_generated_visuals_line.append(vis_line)
		
	# Disable unused nodes
	for i in range(all_shadow_polys.size(), _generated_colliders.size()):
		if not _generated_colliders[i].disabled:
			_generated_colliders[i].set_deferred("disabled", true)
		_generated_visuals_poly[i].visible = false
		_generated_visuals_line[i].visible = false
		
	# Update active nodes
	for i in range(all_shadow_polys.size()):
		var col: CollisionPolygon2D = _generated_colliders[i]
		var vis_poly: Polygon2D = _generated_visuals_poly[i]
		var vis_line: Line2D = _generated_visuals_line[i]
		
		var local_poly := PackedVector2Array()
		for pt in all_shadow_polys[i]:
			local_poly.append(shadow_body.global_transform.affine_inverse() * pt)
			
		col.polygon = local_poly
		if col.disabled:
			col.set_deferred("disabled", false)
		
		vis_poly.polygon = local_poly
		vis_poly.visible = true
		
		vis_line.points = local_poly
		vis_line.visible = true
