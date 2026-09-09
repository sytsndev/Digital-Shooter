class_name Enemy
extends Node

var health: Health
@export var health_res: HealthRes
@export var movement_res: MovementRes
@export var enemy_res: EnemyRes
@export var movement: Movement
@export var nav_agent: NavigationAgent3D
@export var fov_coll: CollisionShape3D

@onready var auto_heal_timer: Timer = $AutoHealTimer
@onready var health_label: Label3D = $Health

var player: Player


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
