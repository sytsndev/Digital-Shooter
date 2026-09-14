class_name Enemy
extends Node

var health: Health
@export var health_res: HealthRes
@export var movement_res: MovementRes
@export var enemy_res: EnemyRes
@export var movement: Movement
@export var nav_agent: NavigationAgent3D
@export var fov_coll: CollisionShape3D
@export var occlusion_ray: RayCast3D

@onready var auto_heal_timer: Timer = $AutoHealTimer
@onready var health_label: Label3D = $Health

var player: Player
var player_in_view: bool = false


func _ready() -> void:
	player = get_tree().root.find_child("Player", true, false)
	health_setup()
	fov_setup()


func _process(delta: float) -> void:
	health_label.text = str(health.curr_health)

#region Setup


func health_setup():
	health = Health.new(health_res.max_health, health_res.min_health, health_res.heal_rate, health_res.heal_rate, health_res.god_mode)
	#player_ui.set_health(health.curr_health, health.max_health)
	health.damage_taken.connect(_on_damage_taken)
	health.dead.connect(_on_death)


func fov_setup():
	var shape = ConvexPolygonShape3D.new()
	
	# Ensure these are floats
	var view_distance: float = float(enemy_res.view_distance)
	var fov_deg: float = float(enemy_res.fov)
	var height: float = float(enemy_res.height)
	
	var fov_rad: float = deg_to_rad(fov_deg)
	var half_fov: float = fov_rad * 0.5
	
	# Far plane half-width from FOV and distance
	var far_half_width: float = view_distance * tan(half_fov)
	
	# Enforce 16:9 aspect on the far plane
	var aspect: float = 16.0 / 9.0
	var far_full_height: float = (far_half_width * 2.0) / aspect
	var far_half_height: float = far_full_height * 0.5
	
	# Near plane uses enemy_res.height
	var near_half_height: float = height * 0.5
	
	var points = PackedVector3Array()
	
	# Near edge (at enemy): vertical segment
	points.append(Vector3(0.0, -near_half_height, 0.0))
	points.append(Vector3(0.0,  near_half_height, 0.0))
	
	# Far rectangle at view_distance with 16:9 aspect
	points.append(Vector3(-far_half_width, -far_half_height, view_distance))
	points.append(Vector3( far_half_width, -far_half_height, view_distance))
	points.append(Vector3(-far_half_width,  far_half_height, view_distance))
	points.append(Vector3( far_half_width,  far_half_height, view_distance))
	
	shape.points = points
	fov_coll.shape = shape
	
	# --- Create debug mesh ---
	_create_fov_debug_mesh(points)


func _create_fov_debug_mesh(points: PackedVector3Array) -> void:
	# Remove any existing debug mesh child
	for child in fov_coll.get_children():
		if child is MeshInstance3D and child.name == "FOVDebugMesh":
			child.queue_free()
	
	var mesh = ArrayMesh.new()
	
	# We'll build triangles manually from the 6 points.
	# Points layout:
	# 0: (0, -near_h, 0)
	# 1: (0,  near_h, 0)
	# 2: (-w, -far_h, d)
	# 3: ( w, -far_h, d)
	# 4: (-w,  far_h, d)
	# 5: ( w,  far_h, d)
	
	var triangles = PackedVector3Array()

	# Bottom face: near bottom point -> far bottom edge
	triangles.append(points[0])
	triangles.append(points[2])
	triangles.append(points[3])

	# Top face: near top point -> far top edge
	triangles.append(points[1])
	triangles.append(points[5])
	triangles.append(points[4])

	# Left side: quad (0, 1, 4, 2)
	triangles.append(points[0])
	triangles.append(points[1])
	triangles.append(points[4])

	triangles.append(points[0])
	triangles.append(points[4])
	triangles.append(points[2])

	# Right side: quad (0, 3, 5, 1)
	triangles.append(points[0])
	triangles.append(points[3])
	triangles.append(points[5])

	triangles.append(points[0])
	triangles.append(points[5])
	triangles.append(points[1])

	# Far face: quad (2, 4, 5, 3)
	triangles.append(points[2])
	triangles.append(points[4])
	triangles.append(points[5])

	triangles.append(points[2])
	triangles.append(points[5])
	triangles.append(points[3])
	
	if Debug.debug_visuals_enable:
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = triangles
		
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		
		var mesh_inst = MeshInstance3D.new()
		mesh_inst.name = "FOVDebugMesh"
		mesh_inst.mesh = mesh
		
		# Simple unshaded material so it's always visible
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(1, 0, 0, 0.4)  # red, semi-transparent
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		
		mesh_inst.set_surface_override_material(0, mat)
		
		fov_coll.add_child(mesh_inst)
		mesh_inst.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else null


#endregion


func _on_damage_taken():
	if auto_heal_timer != null and health_res.is_auto_heal:
		auto_heal_timer.start()
	

func _on_auto_heal_timeout():
	health._start_healing()
	if health.curr_health >= health.max_health:
		auto_heal_timer.stop()


func _on_death():
	queue_free()

func take_damage(damage: float):
	health._take_damage(damage)

func on_ground_pound():
	health._take_damage(100.0)


func _on_player_in_fov(body: Node3D) -> void:
	# Start at enemy position (or some offset like eye height)
	occlusion_ray.global_position = self.global_position  # or enemy.global_position if this script is not on enemy root
	occlusion_ray.target_position = body.global_position - self.global_position  # vector from enemy to player
	
	# Optional: ignore the enemy's own collision layer
	occlusion_ray.collision_mask = 1  # set this to whatever layer(s) the player is on
	
	add_child(occlusion_ray)
	
	# Force immediate update
	occlusion_ray.force_raycast_update()
	
	if occlusion_ray.is_colliding():
		var collider = occlusion_ray.get_collider()
		if collider != body:
			# Something is between enemy and player -> no line of sight
			print("LOS blocked by: ", collider.name)
			return
	
	# If we get here, we have line of sight to the player
	print("Player visible and in LOS")
	player_in_view = true
	


func _on_area_3d_body_exited(body: Node3D) -> void:
	player_in_view = false
