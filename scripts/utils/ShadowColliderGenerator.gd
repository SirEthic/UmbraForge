extends Node2D
class_name ShadowColliderGenerator

@export var light_source: PointLight2D
@export var occluders_parent: Node2D
@export var shadow_length: float = 2000.0

@export_group("Visuals")
@export var fill_color: Color = Color(0.05, 0.05, 0.08, 1.0)
@export var outline_color: Color = Color(0.6, 0.3, 1.0, 1.0)
@export var outline_width: float = 2.0
@export var outline_z_index: int = 0

var _last_light_pos: Vector2
var _last_occluder_transforms: Array[Transform2D] = []
var _was_enabled: bool = true

var _unshaded_material: CanvasItemMaterial

# Dictionary to map each LightOccluder2D to its own exclusive shadow body
var _occluder_bodies: Dictionary = {}

func _ready() -> void:
	z_index = -1
	
	_unshaded_material = CanvasItemMaterial.new()
	_unshaded_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED

func _physics_process(_delta: float) -> void:
	if not light_source or not occluders_parent:
		return
		
	if not light_source.enabled:
		if _was_enabled:
			_clear_all_shadows()
			_was_enabled = false
		return
		
	_was_enabled = true
		
	var needs_update := false
	var light_pos := light_source.global_position
	
	if not light_pos.is_equal_approx(_last_light_pos):
		needs_update = true
		_last_light_pos = light_pos
		
	var current_transforms: Array[Transform2D] = []
	var occluders := _get_all_occluders(occluders_parent)
	
	var active_occluders: Array[LightOccluder2D] = []
	for occ in occluders:
		if is_instance_valid(occ):
			active_occluders.append(occ)
			current_transforms.append(occ.global_transform)
			
	# Cleanup shadow bodies for crates/objects that have been deleted
	var keys = _occluder_bodies.keys()
	for key in keys:
		if not active_occluders.has(key):
			if is_instance_valid(_occluder_bodies[key]):
				_occluder_bodies[key].queue_free()
			_occluder_bodies.erase(key)
			needs_update = true
			
	if current_transforms.size() != _last_occluder_transforms.size():
		needs_update = true
	else:
		for i in range(current_transforms.size()):
			if current_transforms[i] != _last_occluder_transforms[i]:
				needs_update = true
				break
				
	if needs_update:
		_last_occluder_transforms = current_transforms
		_generate_shadow_colliders(light_pos, active_occluders)

func _get_all_occluders(node: Node) -> Array[LightOccluder2D]:
	var result: Array[LightOccluder2D] = []
	if not is_instance_valid(node): return result
	for child in node.get_children():
		if child is LightOccluder2D:
			result.append(child)
		result.append_array(_get_all_occluders(child))
	return result

func _get_or_create_body(occ: LightOccluder2D) -> AnimatableBody2D:
	if _occluder_bodies.has(occ) and is_instance_valid(_occluder_bodies[occ]):
		return _occluder_bodies[occ]
		
	var body = AnimatableBody2D.new()
	body.sync_to_physics = true
	body.collision_layer = 4
	body.collision_mask = 0
	add_child(body)
	_occluder_bodies[occ] = body
	
	# Fix the "Ghost Crate" soft-lock:
	# Inform the physics server that the caster ignores ITS OWN shadow!
	var parent = occ.get_parent()
	if parent is PhysicsBody2D:
		parent.add_collision_exception_with(body)
		
	return body

func _generate_shadow_colliders(light_pos: Vector2, occluders: Array[LightOccluder2D]) -> void:
	for occluder_node in occluders:
		var body := _get_or_create_body(occluder_node)
		
		if not occluder_node.is_visible_in_tree():
			body.process_mode = Node.PROCESS_MODE_DISABLED
			body.visible = false
			continue
			
		body.process_mode = Node.PROCESS_MODE_INHERIT
		body.visible = true
		
		if not occluder_node.occluder:
			continue
			
		var poly: PackedVector2Array = occluder_node.occluder.polygon
		if poly.size() < 3:
			continue
			
		var transform: Transform2D = occluder_node.global_transform
		var global_verts: Array[Vector2] = []
		for i in range(poly.size()):
			global_verts.append(transform * poly[i])
			
		var is_clockwise := Geometry2D.is_polygon_clockwise(global_verts)
		
		# Fix Segmented Shadows: Accumulate into a single merged silhouette!
		var merged_poly := PackedVector2Array(global_verts)
		
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
				
				var res = Geometry2D.merge_polygons(merged_poly, quad)
				if res.size() > 0:
					merged_poly = res[0] # The 0th index is the unified outer boundary. Holes are discarded.
					
		_sync_body_shapes(body, merged_poly)

func _clear_all_shadows() -> void:
	for body in _occluder_bodies.values():
		if is_instance_valid(body):
			for child in body.get_children():
				if child is CollisionPolygon2D and not child.disabled:
					child.set_deferred("disabled", true)
				elif child is Polygon2D or child is Line2D:
					child.visible = false

func _sync_body_shapes(body: AnimatableBody2D, target_poly: PackedVector2Array) -> void:
	var col: CollisionPolygon2D
	var vis_poly: Polygon2D
	var vis_line: Line2D
	
	for child in body.get_children():
		if child is CollisionPolygon2D:
			col = child
		elif child is Polygon2D:
			vis_poly = child
		elif child is Line2D:
			vis_line = child
			
	if not col:
		col = CollisionPolygon2D.new()
		body.add_child(col)
		vis_poly = Polygon2D.new()
		vis_poly.color = fill_color
		vis_poly.material = _unshaded_material
		body.add_child(vis_poly)
		vis_line = Line2D.new()
		vis_line.default_color = outline_color
		vis_line.width = outline_width
		vis_line.closed = true
		vis_line.joint_mode = Line2D.LINE_JOINT_SHARP
		vis_line.material = _unshaded_material
		vis_line.z_index = outline_z_index
		body.add_child(vis_line)
		
	var local_poly := PackedVector2Array()
	for pt in target_poly:
		local_poly.append(body.global_transform.affine_inverse() * pt)
		
	col.polygon = local_poly
	if col.disabled:
		col.set_deferred("disabled", false)
		
	vis_poly.polygon = local_poly
	vis_poly.visible = true
	
	vis_line.points = local_poly
	vis_line.visible = true
