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
@export var attack_coll: CollisionShape3D

@onready var auto_heal_timer: Timer = $AutoHealTimer
@onready var health_label: Label3D = $Health

var player: Player
var player_in_view: bool = false
var player_visible: bool = false


func _ready() -> void:
	player = get_tree().root.find_child("Player", true, false)
	health_setup()
	fov_setup()
	attack_range_setup()


func _process(delta: float) -> void:
	health_label.text = str(health.curr_health)

#region Setup


func health_setup():
	health = Health.new(health_res.max_health, health_res.min_health, health_res.heal_rate, health_res.heal_rate, health_res.god_mode)
	#player_ui.set_health(health.curr_health, health.max_health)
	health.damage_taken.connect(_on_damage_taken)
	health.dead.connect(_on_death)


# Just simplify it and have a huge sphere radius that you check a ray cast if the player is in. I will update this later


func fov_setup():
	# Ensure these are floats
	var view_distance: float = float(enemy_res.view_distance)
	
	fov_coll.shape.radius = view_distance


func attack_range_setup():
	attack_coll.shape.radius = enemy_res.attack_range


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
	player_in_view = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	player_in_view = false
	player_visible = false
	occlusion_ray.target_position = Vector3.ZERO


func check_player_occlussion():
	var player_pos = Vector3(player.global_position.x, player.global_position.y + 0.75, player.global_position.z)
	occlusion_ray.target_position = player_pos - self.global_position  # vector from enemy to player
	
	occlusion_ray.force_raycast_update()
	
	if occlusion_ray.is_colliding():
		var collider = occlusion_ray.get_collider()
		if collider != player:
			player_visible = false
		else:
			player_visible = true


func attack():
	player.health._take_damage(10)


func _on_attack_area_body_entered(body: Node3D) -> void:
	if body is Player:
		attack()
