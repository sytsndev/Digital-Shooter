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
	
	fov_coll.shape.radius = view_distance


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
		print("Test")
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
